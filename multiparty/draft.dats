staload "draft.sats"
staload UN = "prelude/SATS/unsafe.sats"
#define :: seqs 
#define ATS_EXTERN_PREFIX "libsession_"


//implement inspect {self} {p} (session) = let 
//	val+ Session (_, rt, self) = session 
//	val _ = println! ("Inspecting Session:")
//	val _ = println! ("self: ", self)

//	fun spaces (n: nat): void = 
//		if n > 0
//		then (print " "; spaces (n-1))

//	fun show {p:protocol} (level: int, s: rtsession p): void = 
//		case+ p of 
//		| rtskip () => (spaces (level*2); println! "skip")
//		| rtcls () => (spaces (level*2); println! "cls")
//		| rtmsg (a, b) => (spaces (level*2); println! ("msg(", a, "->", b, ")"))
//		| rtchse (a, b, p, q) => (spaces (level*2); println! ("chse(", a, "->", b); show (level+1, p); show (level+1,q))
//		| rtseqs (p, q) => (spaces (level*2); show (level, p); show (level, q))

implement is_equal {p,q} (x, y) = 
	case+ (x, y) of 
	| (rtcls (), rtcls ()) => true 
	| (rtskip (), rtskip ()) => true 
	| (rtmsg (x1, y1), rtmsg (x2, y2)) => x1 = x2 andalso y1 = y2
	| (rtchse (x1, p1, q1), rtchse (x2, p2, q2)) => x1 = x2 andalso is_equal (p1, p2) andalso is_equal (q1, q2)
	| (rtseqs (x1, y1), rtseqs (x2, y2)) => is_equal (x1, x2) andalso is_equal (y1, y2)
	| (_, _) =>> false


implement request {self,arity} {gp,p} (pf | name, self, gp, arity) = let 
	val (pf0 | proj) = project (self, gp)
	val proj = $UN.cast{rtsession p} proj

	// elixir: take a name, and a global session type, get a local session back 
	// the server is responsible for checking global type match
	extern fun _request (name: name gp, rt: rtsession gp, self: int self, arity: int arity): pfsession p = "mac#libsession_request"
	val session = _request (name, gp, self, arity)
in 
	Some (Session(session, proj, self))
end 

implement accept {self} {gp,p} (pf | name, self, gp, task) = let 
	val (_ | proj) = project (self, gp)
	val proj = $UN.cast{rtsession p} proj

	extern fun _accept (pf: PROJ (self, gp, p) | name: name gp, check: rtsession gp -<cloref1> bool, self: int self, task: pfsession p -<lincloptr1> void): void = "mac#libsession_accept"
in
	_accept (pf | 
		name, 
		lam requested => is_equal (requested, gp), 
		self, 
		llam session => 
			let 	
				val _ = task (Some (Session (session, proj, self)))
				prval _ = $UN.cast2void task
				//val _ = cloptr_free ($UN.castvwtp0{cloptr0} task)
			in 
			end
	)
end 

implement project {self} {gp} (self, gp) = 
	case+ gp of 
	| rtcls ()            => (proj_cls () | rtcls ())
	| rtskip ()           => (proj_skip () | rtskip ())
	| rtchse (from, p, q) =>
		let 
			val (pfpp | pp) = project (self, p)
			val (pfqq | qq) = project (self, q)
		in 
		 	(proj_chse (pfpp, pfqq) | rtchse (from, pp, qq))
		 end 
	| rtmsg (from, to) =>
		if to = ~1 
		then 
			if from = self 
			then (proj_msg_broadcast_from () | rtmsg (from, to))
			else (proj_msg_broadcast_to () | rtmsg (from, self))
		else 
			if from = self 
				then (proj_msg_from () | rtmsg (from, to))
			else if to = self 
				then (proj_msg_to() | rtmsg (from, to))
			else 
				(proj_msg_skip () | rtskip ())
	| rtseqs (p, q) => 
		let 
			val (pfpp | pp) = project (self, p)
			val (pfqq | qq) = project (self, q)
		in case+ (pp, qq) of
			| (rtskip (), qq) => (proj_seqs_skipp (pfpp, pfqq) | qq)
			| (pp, rtskip ()) =>> (proj_seqs_skipq (pfpp, pfqq) | pp)
			| (pp, qq) =>> (proj_seqs (pfpp, pfqq) | rtseqs (pp, qq))
		end 




implement send {self,x} {p} {a} (s, payload) = let 
	
	extern fun _send (!pfsession (msg(self, x, a) :: p) >> pfsession p, a): void = "mac#libsession_send"

	val+ @Session(session, rt, self) = s 
	val _ = _send (session, payload)
	val+ rtseqs(rtmsg _, p) = rt 
	val _ = rt := p 
	prval _ = fold@s
in 
	()
end

////


extern fun test_broadcast (): void 
implement test_broadcast () = () where {
	val rt = rtseqs (rtmsg (1, ~1), rtcls ())
	val name = make_name {msg(1,~1,int) :: cls()} ("dummy")
//	prval pf1 = proj_seqs (proj_msg_broadcast_to (), proj_cls ())
	prval pf2 = proj_seqs (proj_msg_broadcast_from (), proj_cls ())

//	val session = request (pf1 | name, 3, rt)
//	val x = receive (session)
//	val _ = close session 

	val session = request (pf2 | name, 1, rt)
	val x = broadcast (session, 100)
	val _ = close session
}


extern fun test1 (): void 
implement test1 () = () where {
	val rt = rtseqs (rtmsg (0, 1), rtseqs (rtmsg (1, 2), rtseqs (rtmsg (2, 0), rtcls ())))
	val name = make_name {msg(0,1,int) :: msg (1,2,int) :: msg (2,0,int) :: cls()} ("dummy")
	prval pf = 
		let 
			#define ++ proj_seqs
			#define -+ proj_seqs_skipp
			infixr ++
			infixr -+
		in 
			proj_msg_to() ++ proj_msg_from() ++ proj_msg_skip() -+ proj_cls()
		end 

	val session = request (pf | name, 1, rt)
	val x = receive (session)
	val _ = send (session, 1)
	val _ = close (session)	
}

extern fun test2 (): void 
implement test2 () = let 
	val rt = rtseqs (rtmsg (0, 1), rtseqs (rtmsg (1, 2), rtseqs (rtmsg (2, 0), rtcls ())))
	val name = make_name {msg(0,1,int) :: msg (1,2,int) :: msg (2,0,int) :: cls()} ("dummy")
	prval pf = 
		let 
			#define ++ proj_seqs
			#define -+ proj_seqs_skipp
			infixr ++
			infixr -+
		in 
			proj_msg_skip() -+ proj_msg_to() ++ proj_msg_from() ++ proj_cls()
		end 


	fun task (session: session (2, msg(1,2,int)::msg(2,0,int)::cls())): void = () where {
		val x = receive (session)
		val _ = send (session, 1)
		val _ = close (session)	
	}
in 
	accept (pf | name, 2, rt, llam session => task session)
end 


extern fun test0 (): void 
implement test0 () = () where {

	val rt = rtseqs (rtmsg (0, 1), rtseqs (rtmsg (1, 2), rtseqs (rtmsg (2, 0), rtcls ())))
	val name = make_name {msg(0,1,int) :: msg (1,2,int) :: msg (2,0,int) :: cls()} ("dummy")
//	val name = make_name ("dummy", rt)
	prval pf = 
		let 
			#define ++ proj_seqs
			#define -+ proj_seqs_skipp
			infixr ++
			infixr -+
		in 
			proj_msg_from() ++ proj_msg_skip() -+ proj_msg_to() ++ proj_cls()
		end 

	val session = request (pf | name, 0, rt)
	val _ = send (session, 1)
	val x = receive (session)
	val _ = close (session)	

//	val _ = $UN.cast2void x

//	val _ = $UN.cast2void session
//	val _ = $showtype rt
//	extern castfn rt2pf {p:protocol} (!rtsession p): pfsession p
//	val pf = rt2pf {msg(0,1,int)::msg(1,2,int)::msg(2,0,int)::cls()} rt 

//	val gs = '{s=pf, r=rt, arity=3}
//	val (pf | s) = project (0, gs): (PROJ (0, msg (0, 1, int) :: msg (1, 2, int) :: msg (2, 0, int) :: cls (), msg (0, 1, int) :: msg (2, 0, int) :: cls ()) | session (0, msg (0, 1, int) :: msg (2, 0, int) :: cls (), 3))

//	val _ = $showtype s.s

//	val _ = send (0, s.s)
}


extern fun test_choose (): void 
implement test_choose () = () where {

	val rt = rtchse(1, 0, rtchse(0, 1, rtcls(), rtcls()), rtcls())
	val name = make_name {chse(1,0,chse(0,1,cls(),cls()),cls())} ("dummy")
	prval pf = 
		let
			#define ++ proj_seqs
			#define -+ proj_seqs_skipp
			#define || proj_chse
			infixr ++
			infixr -+
			infixl ||
		in 
			proj_cls() || proj_cls() || proj_cls() 
		end 

	val session = request (pf | name, 0, rt)
	val _ = choose_fst session
	val _ = offer (session, llam session => close session, llam session => close session)
}


implement main0 () = test0 ()

////
implement project {x} {gp} {arity} (self, gs) = let 

	fun rtproject {gp:protocol} (self: int x, rt: rtsession gp): [p:protocol] (PROJ (x, gp, p) | rtsession p) = let 
		extern praxi proj_cls           {x:nat} ()                              : PROJ (x, cls (), cls ())
		extern praxi proj_msg_from      {x:nat} {y:int} {a:vt@ype} ()           : PROJ (x, msg (x, y, a), msg (x, y, a))
		extern praxi proj_msg_to        {x:nat} {y:int} {a:vt@ype} ()           : PROJ (x, msg (y, x, a), msg (y, x, a))
		extern praxi proj_msg_broadcast {x:nat} {y:int|y != x} {a:vt@ype} ()    : PROJ (x, msg (y, ~1, a), msg (y, x, a))
		extern praxi proj_chse			{x:nat} {y:nat} {c:int} () 			    : PROJ (x, chse (y, c), chse (y, c))

		extern praxi proj_msg_skip      {x:nat} {y,z:nat|x != y && x != z} {a:vt@ype} () : PROJ (x, msg (y, z, a), skip ())
		extern praxi proj_skip 			{x:nat} () 							             : PROJ (x, skip (), skip ())

		extern praxi proj_seqs		 {x:nat} {p,pp,q,qq:protocol} (PROJ (x, p, pp), PROJ (x, q, qq)): PROJ (x, p::q, pp::qq)
		extern praxi proj_seqs_skipp {x:nat} {p,pp,q,qq:protocol} (PROJ (x, p, pp), PROJ (x, q, qq)): PROJ (x, p::q, qq)
		extern praxi proj_seqs_skipq {x:nat} {p,pp,q,qq:protocol} (PROJ (x, p, pp), PROJ (x, q, qq)): PROJ (x, p::q, pp)
//		extern praxi proj {gp,p:protocol} (): PROJ (x, gp, p)
	in  
		case+ rt of 
		| rtcls () => (proj_cls () | rtcls ())
		| rtskip () => (proj_skip () | rtskip ())
		| rtmsg (from, to) => 
			if from = self
				then (proj_msg_from () | rtmsg (from, to))
			else if to = self 
				then (proj_msg_to () | rtmsg (from, to))
			else if to = ~1 
				then (proj_msg_broadcast () | rtmsg (from, self))
			else 
				(proj_msg_skip () | rtskip ())

		| rtchse (from, choice) => (proj_chse () | rtchse (from, choice))
		| rtseqs (p, q) => 
			let 
				val (pfpp | pp) = rtproject (self, p)
				val (pfqq | qq) = rtproject (self, q)
			in case+ (pp, qq) of
				| (rtskip (), qq) => (proj_seqs_skipp (pfpp, pfqq) | qq)
				| (pp, rtskip ()) =>> (proj_seqs_skipq (pfpp, pfqq) | pp)
				| (pp, qq) =>> (proj_seqs (pfpp, pfqq) | rtseqs (pp, qq))
			end 
	end

//	extern castfn pfcreate {gp,p:protocol} (int x, rtsession gp, rtsession p): (PROJ (x, gp, p) | void)
	extern castfn pfproject {gp,p:protocol} (PROJ (x, gp, p) | pfsession gp): pfsession p

	val (pf | rtproj) = rtproject (self, gs.r)
	val pfproj = pfproject (pf | gs.s)
in 
	(pf | '{s=pfproj, r=rtproj, self=self, arity=gs.arity})
end





extern fun test (): void 
implement test () = () where {

	val rt = rtseqs (rtmsg (0, 1), rtseqs (rtmsg (1, 2), rtseqs (rtmsg (2, 0), rtcls ())))
//	val _ = $showtype rt
	extern castfn rt2pf {p:protocol} (rtsession p): pfsession p
	val pf = rt2pf {msg (0, 1, int) :: msg (1, 2, int) :: msg (2, 0, int) :: cls ()} rt 

	val gs = '{s=pf, r=rt, arity=3}
	val (pf | s) = project (0, gs): (PROJ (0, msg (0, 1, int) :: msg (1, 2, int) :: msg (2, 0, int) :: cls (), msg (0, 1, int) :: msg (2, 0, int) :: cls ()) | session (0, msg (0, 1, int) :: msg (2, 0, int) :: cls (), 3))

//	val _ = $showtype s.s

	val _ = send (0, s.s)
}

implement main0 () = test ()

////
implement project {x} {s} (global, ep) = 
	case- global.r of 
	| rtcls {pf} () => (x, pf, rtcls {pf} ())


	////
	| {x,y} {a} rtmsg (x, y) => if x = ep orelse epy = ep then rtmsg (epx, epy) else rtskip ()
	| rtseqs (a, b) => let 
		fun decompose {a,b:type} (prsession (a :: b)): '{prsession a, prsession b} = let 
			

		val '{fst, snd} = decompose
		proja = project (a, ep)