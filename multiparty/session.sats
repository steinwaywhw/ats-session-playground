#define ATS_EXTERN_PREFIX "libsession_"

staload "intset.sats"

(* protocol *)
sortdef protocol = type 

abstype cls () 
abstype skip ()
abstype msg (int, int, vt@ype)
abstype mmsg (set, set, vt@ype)
abstype chse (int, protocol, protocol)
//abstype chse3 (int, type, type, type)
//abstype chse4 (int, type, type, type, type)
abstype seqs (protocol, protocol)
abstype init (set)
abstype rpt (int, protocol)

infixr :: 
#define :: seqs

//postfix ^* 
//#define ^* rpt 

(* util *)
datavtype maybe (a:vtype) =
| Just (a) of a 
| Nothing (a) 

datavtype list (a:vt@ype) = 
| Cons (a) of (a, list a)
| Nil (a) of ()

(*
(* projection *)
dataprop PROJ (self:set, protocol, protocol) = 
(* basis *)
| proj_skip (self, skip(), skip())
| proj_cls  (self, cls(), cls())
(* init *)
| {s:set} proj_init (self, init s, init s)
(* skip *)
| {x,y:nat|(~mem(x,self))*(~mem(y,self))} {a:vt@ype} proj_msg_skip (self, msg(x,y,a), skip())
| {x,y:set|(cap(self,x)==empty_set())*(cap(self,y)==empty_set())} {a:vt@ype} proj_mmsg_skip (self, mmsg(x,y,a), skip())
(* selfloop *)
| {x,y:nat|mem(x,self)*mem(y,self)} {a:vt@ype} proj_msg_self (self, msg(x,y,a), skip())
//| {x,y:set|(~(cap(self,x)==empty_set()))*(~(cap(self,y)==empty_set()))} {a:vt@ype} proj_mmsg_self (self, mmsg(x,y,a), )
(* message *)
| {x,y:nat|mem(x,self) * ~mem(y,self)} {a:vt@ype} proj_msg_from (self, msg(x,y,a), msg(x,y,a))
| {x,y:nat|mem(y,self) * ~mem(x,self)} {a:vt@ype} proj_msg_to   (self, msg(x,y,a), msg(x,y,a))
| {x,y:set|(cap(self,y)==empty_set()) * ~(cap(self,x)==empty_set())} {a:vt@ype} proj_mmsg_from (self, mmsg(x,y,a), mmsg(cap(self,x),y,a))
| {x,y:set|(cap(self,x)==empty_set()) * ~(cap(self,y)==empty_set())} {a:vt@ype} proj_mmsg_to   (self, mmsg(x,y,a), mmsg(x,cap(self,y),a))
(* choose *)
| {x:nat} {p,pp,q,qq:protocol}           proj_chse  (self, chse(x,p,q), chse(x,pp,qq)) of (PROJ(self,p,pp), PROJ(self,q,qq))
| {x:nat} {p,pp,q,qq,r,rr:protocol}      proj_chse3 (self, chse3(x,p,q,r), chse3(x,pp,qq,rr)) of (PROJ(self,p,pp), PROJ(self,q,qq), PROJ(self,r,rr))
| {x:nat} {p,pp,q,qq,r,rr,s,ss:protocol} proj_chse4 (self, chse4(x,p,q,r,s), chse4(x,pp,qq,rr,ss)) of (PROJ(self,p,pp), PROJ(self,q,qq), PROJ(self,r,rr), PROJ(self,s,ss))
(* seqs *)
| {p,pp,q,qq:protocol} proj_seqs 	   (self, p::q, pp::qq) of (PROJ(self,p,pp), PROJ(self,q,qq))
| {p,q,qq:protocol}    proj_seqs_skipp (self, p::q, qq) of (PROJ(self,p,skip()), PROJ(self,q,qq))
| {p,pp,q:protocol}	   proj_seqs_skipq (self, p::q, pp) of (PROJ(self,p,pp), PROJ(self,q,skip()))
(* repeat *)
| {x:nat} {p,pp:protocol} proj_rpt      (self, rpt(x,p), rpt(x,pp)) of (PROJ(self,p,pp))
| {x:nat} {p:protocol}    proj_rpt_skip (self, rpt(x,p), skip()) of (PROJ(self,p,skip()))
*)

(* session *)
absvtype pfsession (protocol) = ptr 
datatype rtsession (protocol) = 
| rtcls (cls ()) of ()
| rtskip (skip ()) of ()
| {s:set} rtinit (init s) of (set s)
| {a:vt@ype} {x,y:nat} rtmsg (msg (x, y, a)) of (int x, int y)
| {a:vt@ype} {x,y:set} rtmmsg (mmsg (x, y, a)) of (set x, set y) 
| {x:nat} {p,q:protocol} rtchse (chse (x, p, q)) of (int x, rtsession p, rtsession q)
//| {x:nat} {p,q,r:protocol} rtchse3 (chse3 (x, p, q, r)) of (int x, rtsession p, rtsession q, rtsession r)
//| {x:nat} {p,q,r,t:protocol} rtchse4 (chse4 (x, p, q, r, t)) of (int x, rtsession p, rtsession q, rtsession r, rtsession t)
| {p,q:protocol} rtseqs (seqs (p, q)) of (rtsession p, rtsession q)
| {x:nat} {p:protocol} rtrpt (rpt (x, p)) of (rtsession p)


//vtypedef session (self:int, p:protocol) = @{session = pfsession p, rt = rtsession p, self = int self}
absvtype session (self:set, s:set, gp:protocol)
//#include "contrib/libatscc/libatscc2erl/staloadall.hats"
//vtypedef rtsessionref (p:protocol) = ref_vt (rtsession p)
//datavtype session (self:set, s:set, gp:protocol) = Session (self, s, gp) of (pfsession gp, rtsessionref gp, set self, set s)

//	| Session (self, s, gp) of (pfsession gp, rtsessionref gp, set self, set s)

(* name *)
abstype name (set, protocol)
fun make_name {s:set} {gp:protocol} (set s, rtsession (gp), string): name (s, init(s)::gp)

(* session init *)
fun init 
	{self,s:set|sub(self,s)} {gp:protocol} 
	(name (s, init(s)::gp), set self, maybe (session (self,s,gp)) -<lincloptr1> void)
	: void 


fun create 
	{x,y,s:set|(cup(x,y)==s)*(cap(x,y)==empty_set())} {gp:protocol}
	(set x, set y, rtsession (init(s)::gp), maybe (session (y,s,gp)) -<lincloptr1> void) 
	: maybe (session (x,s,gp))


(* project *)
(* TODO make it internal *)
//fun project {self,s:set} {gp:protocol} (set self, rtsession (s, gp)) : [p:protocol] (PROJ (self, gp, p) | rtsession (self, p))
fun is_equal {p,q:protocol} (rtsession p, rtsession q): bool 

(* primitives *)
fun send    
	{self,s:set} {x,y:nat|mem(x,self) * ~mem(y,self)} {gp:protocol} {a:vt@ype} 
	(!session (self, s, msg(x,y,a)::gp) >> session (self, s, gp), int y, a)
	: void 

fun receive 
	{self,s:set} {x,y:nat|mem(y,self) * ~mem(x,self)} {gp:protocol} {a:vt@ype} 
	(!session (self, s, msg(x,y,a)::gp) >> session (self, s, gp), int x)
	: a


abstype foreach (int, bool, protocol)

fun proj_foreach 
	{self,s:set} {i:int} {p:protocol} {b:bool|b == true}
	(!session (self, s, foreach (i, b, p)) >> session (self, s, p :: foreach (i+1, b, p)), int i)
	: void 

//fun msend
//	{self,s:set} {x,y:set|sub(s,x)*sub(s,y)*sub(self,x)*(cap(y,self)==empty_set())} {n:nat|mem(n,x)} {gp:protocol} {a:vt@ype}
//	(!session (self, s, mmsg(x,y,a)::gp) >> session (self, s, mmsg(del(x,n),y,a)::gp), int n, set y, a)
//	: void

//fun mreceive
//	{self,s:set} {x,y:set|sub(s,x)*sub(s,y)*(cap(x,self)==empty_set())*sub(self,y)} {n:nat|mem(n,y)} {gp:protocol} {a:vt@ype}
//	(!session (self, s, mmsg(x,y,a)::gp) >> session (self, s, mmsg(x,del(y,n),a)::gp), set x, int n)
//	: list a
 
//fun msend 
//	{self,s:set} {x,y:set|sub(s,x)*sub(s,y)*(cap(x,self)!=empty_set())*()}

//fun mreceive 
//	{self,s:set} {x,y:set|sub(s,x)*sub(s,y)*(cap(x,self)==empty_set())*(cap(y,self)!=empty_set())} {gp:protocol} {a:vt@ype}
//	(!session (self, s, mmsg(x,y,a)::gp) >> session (self, s, gp), set x, set y)
//	: list a

fun skip_msg
	{self,s:set} {x,y:nat|(~mem(x,self) * ~mem(y,self)) + (x==y)} {gp:protocol} {a:vt@ype}
	(!session (self, s, msg(x,y,a)::gp) >> session (self, s, gp))
	: void 

fun skip_mmsg
	{self,s:set} {x,y:set|(cap(self,x)==empty_set()) * (cap(self,y)==empty_set())} {gp:protocol} {a:vt@ype}
	(!session (self, s, mmsg(x,y,a)::gp) >> session (self, s, gp))
	: void 

fun proj_mmsg 
	{self,s:set} {x,y:set} {gp:protocol} {a:vt@ype}
	(!session (self, s, mmsg(x,y,a)::gp) >> session (self, s, mmsg(cap(x,self), dif(y,self), a)::mmsg(dif(x,self), cap(y,self), a)::gp))
	: void

fun close 
	{self,s:set}
	(session (self, s, cls()))
	: void 

fun link 
	{x,y,s:set|(dif(s,x) \cap dif(s,y))==empty_set()} {gp:protocol}
	(session (x,s,gp), session (y,s,gp))
	: session (dif(s, (dif(s,x) \cup dif(s,y))), s, gp) 

datavtype choice (protocol, p:protocol, q:protocol) =
| ChooseFst (p, p, q) of ()
| ChooseSnd (q, p, q) of ()

fun offer 	   
	{self,s:set} {x:nat|(~mem(x,self))} {p,q:protocol} 
	(!session (self, s, chse(x,p,q)) >> session (self, s, r), int x)
	: #[r:protocol] choice (r, p, q)

fun choose_fst 
	{self,s:set} {x:nat|mem(x,self)} {p,q:protocol} 
	(!session (self, s, chse(x,p,q)) >> session (self, s, p))
	: void 

fun choose_snd 
	{self,s:set} {x:nat|mem(x,self)} {p,q:protocol} 
	(!session (self, s, chse(x,p,q)) >> session (self, s, q))
	: void


////
fun unroll_rpt {self:nat} {p,q:protocol} (!session (self, rpt(p)::q) >> session (self, p::rpt(p)::q)): void 
fun unroll_rptn {self:nat} {n:nat|n > 0} (!session (self, rptn (p, n)) >> session (self, p :: rptn (p, n-1)): void 
fun unroll_rpt0 {self:nat} (!session (self, rptn (p, 0)) >> )

fun close {self:nat} (session (self, cls())): void

fun inspect {self:nat} {p:protocol} (!session (self, p)): void






//fun create {} (list (llam session -> void, n-1)): session 
////

//vtypedef rtsession (p:protocol, arity:int) = rtsession p 



//typedef gsession (p:protocol, arity:int) = '{s = pfsession p, r = rtsession p, arity = int arity}
//typedef session (self:int, p:protocol, arity:int) = '{s = pfsession p, r = rtsession p, self = int self, arity = int arity}

//vtypedef session (self:endpt, p:protocol, arity:nat) = pfsession (p, arity)

//fun request {arity:nat} {x:endpt|x<arity} {gp:protocol} (int x, rtsession (gp, arity), int arity): [p:protocol] (PROJ (x, gp, p) | session (x, p, arity))
//fun accpet  {arity:nat} {x:endpt|x<arity} {gp:protocol} (int x, rtsession (gp, arity), int arity): [p:protocol] (PROJ (x, gp, p) | session (x, p, arity))

//fun validate {(rtsession (p, a), rtsessino (q, b)): void
//absprop PROJ (int, protocol, protocol) // (endpt, global protocol, local protocol)
//datavtype rtsession (protocol, arity:int) = 
//| rtcls (cls (), arity) of ()
//| rtskip (skip (), arity) of ()
//| {a:vt@ype} {x:endpt|x < arity} {y:endpt_bc|y < arity} rtmsg (msg (x, y, a), arity) of (int x, int y)
//| {x:endpt|x < arity} {n:nat} rtchse (chse (x, n), arity) of (int x, int n)
//| {p,q:protocol} rtseqs (seqs (p, q), arity) of (rtsession (p, arity), rtsession (q, arity))

//extern praxi proj_cls           {x:nat} ()                              : PROJ (x, cls (), cls ())
//extern praxi proj_msg_from      {x:nat} {y:int} {a:vt@ype} ()           : PROJ (x, msg (x, y, a), msg (x, y, a))
//extern praxi proj_msg_to        {x:nat} {y:int} {a:vt@ype} ()           : PROJ (x, msg (y, x, a), msg (y, x, a))
//extern praxi proj_msg_broadcast {x:nat} {y:int|y != x} {a:vt@ype} ()    : PROJ (x, msg (y, ~1, a), msg (y, x, a))
//extern praxi proj_chse			{x:nat} {y:nat} {c:int} () 			    : PROJ (x, chse (y, c), chse (y, c))

//extern praxi proj_msg_skip      {x:nat} {y,z:nat|x != y && x != z} {a:vt@ype} () : PROJ (x, msg (y, z, a), skip ())
//extern praxi proj_skip 			{x:nat} () 							             : PROJ (x, skip (), skip ())

//extern praxi proj_seqs		    {x:nat} {p,pp,q,qq:protocol} (PROJ (x, p, pp), PROJ (x, q, qq)): PROJ (x, p::q, pp::qq)
//extern praxi proj_seqs_skipp    {x:nat} {p,q,qq:protocol}    (PROJ (x, p, skip ()), PROJ (x, q, qq)): PROJ (x, p::q, qq)
//extern praxi proj_seqs_skipq    {x:nat} {p,pp,q:protocol}    (PROJ (x, p, pp), PROJ (x, q, skip ())): PROJ (x, p::q, pp)

//fun project {x:nat} {gp:protocol} {arity:nat|x < arity} (int x, gsession (gp, arity)): [p:protocol] (PROJ (x, gp, p) | session (x, p, arity))
//fun send {x:nat} {p:protocol} {arity:nat} {y:int|y >= ~1 && y < arity} {a:vt@ype} (int x, !pfsession (msg (x,y,a) :: p) >> pfsession p, a): void = "mac#"



////
absprop PROJ (int, type, type)

sortdef endpt = int 
sortdef protocol = type

abstype cls ()
abstype msg (endpt, endpt, vt@ype)
abstype seqs (protocol, protocol) 
#define :: seqs

abstype name (protocol) = ptr

absvtype prsession (protocol) = ptr 
datavtype rtsession (protocol) = 
| {p:protocol} rtskip (p) of ()
| rtcls (cls ()) of () 
| {x,y:endpt} {a:vt@ype} rtmsg (msg (x, y, a)) of (int x, int y)
| {p,q:protocol} rtseqs (seqs (p, q)) of (rtsession p, rtsession q)

vtypedef gsession (p:protocol) = '{p = prsession p, r = rtsession p}
vtypedef session (x:endpt, p:protocol) = '{self = int x, p = prsession p, r = rtsession p}

fun send {x,y:endpt} {a:vt@ype} {p:protocol} (!session (x, msg(x, y, a) :: p) >> session (x, p), int y , a): void
fun recv {x,y:endpt} {a:vt@ype} {p:protocol} (!session (x, msg(y, x, a) :: p) >> session (x, p), int y): a

fun accpet  {x:endpt} {p:protocol} (name p, gsession p, x): [ss:protocol] (PROJ (x, p, ss) | session (x, ss))
fun request {x:endpt} {p:protocol} (name p, gsession p, x): [ss:protocol] (PROJ (x, p, ss) | session (x, ss))
fun project {x:endpt} {p:protocol} (gsession p, x): [ss:protocol] (PROJ (x, p, ss) | session (x, ss))








