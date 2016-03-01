#define ATS_EXTERN_PREFIX "libsession_"

staload "intset.sats"


datasort protocol = (* abstract *)


stacst cls: () -> protocol
stacst skip: () -> protocol
stacst msg: (int, int, vt@ype) -> protocol
//stacst mmsg: (set, set, vt@ype) -> protocol
stacst seqs: (protocol, protocol) -> protocol
//stacst chse: (int, protocol, protocol) -> protocol
stacst init: (set) -> protocol
//stacst rpt: (int, protocol) -> protocol


stacst proto_proj: (protocol, set) -> protocol
stacst proto_eq: (protocol, protocol) -> bool

(**)


stadef == = proto_eq 
stadef @@ = proto_proj 
stadef :: = seqs

infix 30 ==
infix 31 @@
infixr 40 ::

(**)

praxi proto_eq_cls (): [cls()==cls()] unit_p
praxi proto_eq_skip (): [skip()==skip()] unit_p
praxi proto_eq_msg {x,y:nat} {a:vt@ype} (): [msg(x,y,a)==msg(x,y,a)] unit_p
praxi proto_eq_seqs {p,q:protocol} (): [p::q==p::q] unit_p
praxi proto_eq_init {s:set} (): [init(s)==init(s)] unit_p

absvtype session (protocol)


fun test(): session(msg(1,2,int)::cls())
fun test2 {p:protocol} (!session(msg(1,2,int)::p) >> session p): void 
fun test3 (session(cls())): void



////

(* protocol *)
sortdef protocol = type 

abstype cls () 
abstype skip ()
abstype msg (int, int, vt@ype)
abstype mmsg (set, set, vt@ype)
abstype chse (int, type, type)
abstype chse3 (int, type, type, type)
abstype chse4 (int, type, type, type, type)
abstype seqs (type, type)
abstype init (set)
abstype rpt (int, type)

#define :: seqs
infixr :: 

#define ^* rpt 
postfix ^*

(* util *)
datavtype option (a:vtype) =
| Some (a) of a 
| None (a) 

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


(* session *)
absvtype pfsession (set, protocol) = ptr 
datatype rtsession (s:set, protocol) = 
| rtcls (s,cls ()) of ()
| rtskip (s,skip ()) of ()
| rtinit (s,init s) of (set s)
| {a:vt@ype} {x,y:nat|(x != y)*mem(x,s)*mem(y,s)} rtmsg (s, msg (x, y, a)) of (int x, int y)
| {a:vt@ype} {x,y:set|(cap(x,y)==empty_set())*sub(x,s)*sub(y,s)} rtmmsg (s, mmsg (x, y, a)) of (set x, set y) 
| {x:nat|mem(x,s)} {p,q:protocol} rtchse (s, chse (x, p, q)) of (int x, rtsession(s,p), rtsession(s,q))
| {x:nat|mem(x,s)} {p,q,r:protocol} rtchse3 (s, chse3 (x, p, q, r)) of (int x, rtsession(s,p), rtsession(s,q), rtsession(s,r))
| {x:nat|mem(x,s)} {p,q,r,t:protocol} rtchse4 (s, chse4 (x, p, q, r, t)) of (int x, rtsession(s,p), rtsession(s,q), rtsession(s,r), rtsession(s,t))
| {p,q:protocol} rtseqs (s, seqs (p, q)) of (rtsession(s,p), rtsession(s,q))
| {x:nat|mem(x,s)} {p:protocol} rtrpt (s, rpt (x, p)) of (rtsession(s,p))

typedef rtsessionref (s:set, p:protocol) = ref (rtsession (s, p))

//vtypedef session (self:int, p:protocol) = @{session = pfsession p, rt = rtsession p, self = int self}
datavtype session (self:set, p:protocol, s:set, gp:protocol) = 

	| Session (self, p, s, gp) of (pfsession (self, p), set self, rtsessionref (self, p), set s, rtsession (s, gp))


(* name *)
abstype name (set, protocol) = ptr 
fun make_name {s:set} {gp:protocol} (set s, string): name (s, gp)

(* session init *)
fun init 
	{self,s:set|sub(self,s)} {gp,p:protocol} 
	(PROJ (self, gp, p) 
	| name (s, init(s)::gp), set s, rtsession (s, init(s)::gp), set self, option (session (self, p, s, gp)) -<lincloptr1> void)
	: void 


fun create 
	{x,y,s:set|(cup(x,y)==s)*(cap(x,y)==empty_set())} {gp,p,q:protocol} 
	(PROJ(x,gp,p), PROJ(y,gp,q) 
	| rtsession(s,gp), option(session(x,p,s,gp)) -<lincloptr1> void, option(session(y,q,s,gp)) -<lincloptr1> void)
	: void


(* project *)
(* TODO make it internal *)
fun project {self,s:set} {gp:protocol} (set self, rtsession (s, gp)) : [p:protocol] (PROJ (self, gp, p) | rtsession (self, p))
fun is_equal {s,r:set} {p,q:protocol} (rtsession (s,p), rtsession (r,q)): bool 

(* primitives *)
fun send    
	{self,s:set} {x,y:nat|mem(x,self) * ~mem(y,self)} {p,gp:protocol} {a:vt@ype} 
	(!session (self, msg(x,y,a) :: p, s, gp) >> session (self, p, s, gp), a)
	: void 

fun receive 
	{self,s:set} {x,y:nat|mem(y,self) * ~mem(x,self)} {p,gp:protocol} {a:vt@ype} 
	(!session (self, msg(x,y,a) :: p, s, gp) >> session (self, p, s, gp))
	: a

fun close 
	{self,s:set} {gp:protocol}
	(session (self, cls(), s, gp))
	: void 

//fun broadcast {self:nat} {p:protocol} {a:vt@ype} (!session (self, msg(self,~1,a) :: p) >> session (self, p), a): void

fun merge 
	{x,y,s:set|(cap(x,y)==empty_set())} {p,q,r,gp:protocol} 
	(PROJ (cup(x,y), r, gp) 
	| session(x,p,s,gp), session(y,q,s,gp))
	: session(cup(x,y),r,s,gp)

fun link 
	{x,y,s:set|not(cap(x,y)==empty_set())} {p,q,r,gp:protocol} 
	(PROJ (dif(s,cup(dif(s,x),dif(s,y))), r, gp)
	| session(x,p,s,gp), session(y,q,s,gp))
	: session(dif(s,cup(dif(s,x),dif(s,y))),r,s,gp)


datavtype choice (protocol, p:protocol, q:protocol) =
| ChooseFst (p, p, q) of ()
| ChooseSnd (q, p, q) of ()

fun offer 	   
	{self,s:set} {x:nat|(~mem(x,self))} {p,q,gp:protocol} 
	(!session (self, chse(x,p,q), s, gp) >> session (self, r, s, gp))
	: #[r:protocol] choice (r, p, q)

fun choose_fst 
	{self,s:set} {x:nat|mem(x,self)} {p,q,gp:protocol} 
	(!session (self, chse(x,p,q), s, gp) >> session (self, p, s, gp))
	: void 

fun choose_snd 
	{self,s:set} {x:nat|mem(x,self)} {p,q,gp:protocol} 
	(!session (self, chse(x,p,q), s, gp) >> session (self, q, s, gp))
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








