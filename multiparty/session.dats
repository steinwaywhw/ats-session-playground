#define ATS_EXTERN_PREFIX "libsession_"
#define ATS_DYNLOADFLAG 0
#include "contrib/libatscc/libatscc2erl/staloadall.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/ML/SATS/basis.sats"
staload "session.sats"
staload "intset.sats"
staload "list.sats"

(* some erlang code to be included after compilation *)
%{^
-compile(nowarn_unused_vars).
-compile(nowarn_unused_function).
-compile(export_all).
-include("$PATSHOMERELOC/contrib/libatscc/libatscc2erl/libatscc2erl_all.hrl").
-include("./session.hrl").
%} // end of [%{]

#include "intset.dats"

(* utilities *)
infixr ::
#define :: seqs 

infixr ** 
#define ** rtseqs

(* realizing abstract types *)
assume name (s:set, p:protocol) = '(set s, rtsession p, atom)
datavtype _session (self:set, s:set, gp:protocol) = Session (self, s, gp) of (pfsession gp, (*rtsessionref gp,*) set self, set s)
assume session (self:set, s:set, gp:protocol) = _session (self, s, gp)


(**)
local 
(**)

(* for discharging set constraints to external SMT solver *)
prval _ = $solver_assert (set_range_base)
prval _ = $solver_assert (set_range_ind)
prval _ = $solver_assert (set_range_lemma1)
prval _ = $solver_assert (set_range_lemma2)

(* some utility functions defined in erlang *)
typedef erlval = ERLval

extern fun is_atom (erlval): bool = "mac#is_atom"
extern fun spawn (() -<lincloptr1> void): pid = "mac#%"
extern fun spawn_link (() -<lincloptr1> void): pid = "mac#%"
extern fun make_ref (): erlval = "mac#%"
extern fun debug(string): void = "mac#%"
extern fun inspect {a:type} (a): string = "mac#%"

fun set2erl {s:set} (s: set s): erlval = let 
	extern fun _set2erl (set s, (set s, erlval, (int, erlval) -> erlval) -<cloref1> erlval): erlval = "mac#%"
	fun set_reduce {s:set} (s: set s, base: erlval, f: (int, erlval) -> erlval): erlval = 
		case+ s of 
		| Empty () => base 
		| Elem (n, s) => f (n, set_reduce (s, base, f))
in 
	_set2erl (s, lam (s, base, f) => set_reduce (s, base, f))
end

(**)
in 
(**)


implement make_name {s} {gp} (parts, rt, name) = 
	$tup(parts, rtinit (parts) ** rt, string2atom name)

implement is_equal {p,q} (x, y) = 
	case+ (x, y) of 
	| (rtcls (), rtcls ()) => true 
	| (rtskip (), rtskip ()) => true 
	| (rtmsg (x1, y1), rtmsg (x2, y2)) => x1 = x2 andalso y1 = y2
	| (rtmmsg (x1, y1), rtmmsg (x2, y2)) => (x1 \set_eq x2) andalso (y1 \set_eq y2)
	| (rtchse (x1, p1, q1), rtchse (x2, p2, q2)) => x1 = x2 andalso is_equal (p1, p2) andalso is_equal (q1, q2)
	| (rtseqs (x1, y1), rtseqs (x2, y2)) => is_equal (x1, x2) andalso is_equal (y1, y2)
	| (rtrpt (p), rtrpt (q)) => is_equal (p, q)
	| (_, _) =>> false

implement init {self,s} {gp} (name, self, loop) = let 
	val parts = name.0
	val rt = name.1
	val atom = name.2

	extern fun _init (
		name: atom, 
		self: erlval, 
		parts: erlval,
		rt: rtsession (init(s)::gp))
		: erlval = "mac#%"

	(* put the blocking init into a separate thread *)
	val _ = spawn_link (
		llam () => let 
			(* register, block wait, check, and return either session or :no *)
			val pf = _init (atom, set2erl self, set2erl parts, rt)

			(* create maybe (session) *)
			val session = 
				(if is_atom pf 
				 then Nothing ()
 				 else Just (Session ($UN.castvwtp0{pfsession gp}(pf), self, parts))
				): maybe (session (self, s, gp))

			(* start session *)
			val _ = loop session 
			prval _ = $UN.cast2void loop 
		in 
		end)
in
	()
end

implement create {x,y,s} {gp} (self, other, rt, fother) = let 

	val random = make_ref ()
	val+ rtinit(parts) ** _ = rt

	extern fun _init (
		name: erlval, 
		self: erlval, 
		parts: erlval,
		rt: rtsession (init(s)::gp))
		: erlval = "mac#%"

	(* create the other *)
	val _ = spawn (
		llam () => let 
			(* register, block wait, check, and return either pid or :no *)
			val pf = _init (random, set2erl other, set2erl parts, rt)

			(* create maybe (session) *)
			val session = 
				(if is_atom pf 
				 then Nothing ()
 				 else Just (Session ($UN.castvwtp0{pfsession gp}(pf), other, parts))
				): maybe (session (y, s, gp))

			val _ = fother session 
			prval _ = $UN.cast2void fother 
		in 
		end)

	(* create myself *)
	val pf = _init (random, set2erl self, set2erl parts, rt)

	(* create maybe (session) *)
	val session = 
		(if is_atom pf 
		 then Nothing ()
		 else Just (Session ($UN.castvwtp0{pfsession gp} pf, self, parts))
		): maybe (session (x, s, gp))

in 
	session 
end


implement send {self,s} {x,y} {gp} {a} (session, to, payload) = let 

	val+ @Session(pf, self, s) = session

	extern fun _send (!pfsession (msg(x, y, a) :: gp) >> pfsession gp, int y, a): void = "mac#%"
	val _ = _send (pf, to, payload)
	prval _ = fold@session
in 
	()
end

implement receive {self,s} {x,y} {gp} {a} (session, from) = let 

	extern fun _recv (!pfsession (msg(x,y,a)::gp) >> pfsession gp, int x): a = "mac#%"

	val+ @Session(pf, self, s) = session
	val res = _recv (pf, from)
	prval _ = fold@session
in 
	res 
end 

implement skip_msg {self,s} {x,y} {gp} {a} (session) = let 
	val+ @Session(pf, self, s) = session 
	prval _ = $UN.castview2void pf 
	prval _ = fold@session 
in 
	() 
end

implement close {self,s} (session) = let 
	extern fun _close (pfsession (cls())): void = "mac#%"
	val+ ~Session(pf, self, s) = session 

	val _ = _close (pf)
in 
	() 
end 

implement link {x,y,s} {gp} (sessionx, sessiony) = let 
	extern fun _link (pfsession gp, pfsession gp): pfsession gp = "mac#%"

	val+ ~Session(pfx, x, s) = sessionx
	val+ ~Session(pfy, y, s) = sessiony

	val self = s \set_difference ((s \set_difference x) \set_union (s \set_difference y))

	val pf = _link (pfx, pfy)

in 
	Session (pf, self, s)
end 

implement offer {self,s} {x} {p,q} (session, from) = let 
	extern fun _offer (!pfsession (chse(x,p,q)), int x): int = "mac#%"

	val+ @Session (pf, self, s) = session 
	val label = _offer (pf, from)

in 
	if label = 0 
	then let 
		prval _ = $UN.castview2void pf 
		prval _ = fold@session 
		in ChooseFst {p,q} () end
	else let 
		prval _ = $UN.castview2void pf 
		prval _ = fold@session
		in ChooseSnd {p,q} () end 
end 

implement choose_fst {self,s} {x} {p,q} (session) = let 
	extern fun _choose (!pfsession (chse(x,p,q)) >> pfsession p, int 0): void = "mac#%"

	val+ @Session (pf, self, s) = session 
	val _ = _choose (pf, 0)
	prval _ = fold@session 
in 
	() 
end 

implement choose_snd {self,s} {x} {p,q} (session) = let 
	extern fun _choose (!pfsession (chse(x,p,q)) >> pfsession q, int 1): void = "mac#%"

	val+ @Session (pf, self, s) = session 
	val _ = _choose (pf, 1)
	prval _ = fold@session 
in 
	() 
end 



(* work in progress *)

implement skip_mmsg {self,s} {x,y} {gp} {a} (session) = let 	
	val+ @Session(pf, self, s) = session 
	prval _ = $UN.castview2void pf 
	prval _ = fold@session 
in 
	() 
end


implement proj_mmsg {self,s} {x,y} {gp} {a} (session) = let 
	val+ @Session(pf, self, s) = session 
	prval _ = $UN.castview2void pf 
	prval _ = fold@session 
in 
	() 
end

(**)
end
(**)


