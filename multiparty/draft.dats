staload "draft.sats"


implement project {x} {gp} {arity} (self, gs) = let 

	fun rtproject {gp:protocol} (self: int x, gs: rtsession gp): [p:protocol] rtsession p = let 
//		extern praxi proj_cls {x:int|x >= 0} (): PROJ (x, cls(), cls())
//		extern praxi proj_skip {x:int|x >= 0} {gp,p:protocol} (): PROJ (x, gp, p)
//		extern praxi proj_msg_from {x:int|x >= 0} {y:int} {a:vt@ype} (): PROJ (x, msg (x, y, a), msg (x, y, a))
//		extern praxi proj_msg_to {x:int|x >= 0} {y:int} {a:vt@ype} (): PROJ (x, msg (y, x, a), msg (y, x, a))
//		extern praxi proj_msg_broadcast {x:int|x >= 0} {y:int|y != x} {a:vt@ype} (): PROJ (x, msg (y, ~1, a), msg (y, x, a))

//		extern praxi proj {gp,p:protocol} (): PROJ (x, gp, p)
	in  
		case+ gs of 
		| rtcls () => rtcls ()
		| rtskip () => rtskip ()
		| rtmsg (from, to) => 
			if from = self orelse to = self
			then rtmsg (from, to)
			else if to = ~1 then rtmsg (from, self) else rtskip ()
		| rtchse (from, choice) => rtchse (from, choice)
		| rtseqs (p, q) => 
			let 
				val pp = rtproject (self, p)
				val qq = rtproject (self, q)
			in case+ (pp, qq) of
				| (rtskip (), q) => q
				| (p, rtskip ()) =>> p
				| (p, q) =>> rtseqs (p, q)
			end 
	end

	extern castfn pfcreate {gp,p:protocol} (int x, rtsession gp, rtsession p): (PROJ (x, gp, p) | void)
	extern castfn pfproject {gp,p:protocol} (PROJ (x, gp, p) | pfsession gp): pfsession p

	val rtproj = rtproject (self, gs.r)
	val (pf | _) = pfcreate (self, gs.r, rtproj)
	val pfproj = pfproject (pf | gs.s)
in 
	(pf | '{s=pfproj, r=rtproj, self=self, arity=gs.arity})
end







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