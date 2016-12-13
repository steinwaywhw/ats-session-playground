#define ATS_EXTERN_PREFIX "libsession_"
staload "intset.sats"

(* protocol *)
sortdef protocol = type 

abstype cls () 
abstype skip ()
abstype msg (int, int, vt@ype)
abstype mmsg (set, set, vt@ype)
abstype chse (int, protocol, protocol)
abstype seqs (protocol, protocol)
abstype init (set)
abstype rpt (int, protocol)
abstype forasc (min: int, max: int, subprotocol: int->protocol)
abstype fordes (min: int, max: int, subprotocol: int->protocol)

infixr :: 
#define :: seqs

(* utilities *)
datavtype maybe (a:vtype) =
| Just (a) of a 
| Nothing (a) 

datavtype list (a:vt@ype) = 
| Cons (a) of (a, list a)
| Nil (a) of ()

(* session *)
absvtype pfsession (protocol) = ptr (* for representing underlying erlang endpoints *)
datatype rtsession (protocol) =  
| rtcls (cls ()) of ()
| rtskip (skip ()) of ()
| {s:set} rtinit (init s) of (set s)
| {a:vt@ype} {x,y:nat} rtmsg (msg (x, y, a)) of (int x, int y)
| {a:vt@ype} {x,y:set} rtmmsg (mmsg (x, y, a)) of (set x, set y) 
| {x:nat} {p,q:protocol} rtchse (chse (x, p, q)) of (int x, rtsession p, rtsession q)
| {p,q:protocol} rtseqs (seqs (p, q)) of (rtsession p, rtsession q)
| {x:nat} {p:protocol} rtrpt (rpt (x, p)) of (rtsession p)
(* TODO: foreach *)

absvtype session (self:set, s:set, gp:protocol)

(* name *)
abstype name (set, protocol)
fun make_name {s:set} {gp:protocol} (set s, rtsession (gp), string): name (s, init(s)::gp)

(* session init *)

(* init a session, in a totally distributed manner.
   every participant(s) issues a request to the name server
   and they start altogether *)
fun init 
	{self,s:set|sub(self,s)} {gp:protocol} 
	(name (s, init(s)::gp), set self, maybe (session (self,s,gp)) -<lincloptr1> void)
	: void 

(* init a session, in a non-distributed manner.
   the current thread get an endpoint, and the other thread get the dual *)
fun create 
	{x,y,s:set|(cup(x,y)==s)*(cap(x,y)==empty_set())} {gp:protocol}
	(set x, set y, rtsession (init(s)::gp), maybe (session (y,s,gp)) -<lincloptr1> void) 
	: maybe (session (x,s,gp))

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

fun skip 
	{self,s:set} {gp:protocol}
	(!session (self, s, skip() :: gp) >> session (self, s, gp))
	: void 

fun skip_msg
	{self,s:set} {x,y:nat|(~mem(x,self) * ~mem(y,self)) + (x==y)} {gp:protocol} {a:vt@ype}
	(!session (self, s, msg(x,y,a)::gp) >> session (self, s, gp))
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


(* work in progress *)

fun flatten
	{self,s:set} {p,q,r:protocol}
	(!session (self, s, (p::q)::r) >> session (self, s, p::q::r))
	: void 

fun foreach_asc_unroll
	{self,s:set} {sub:int->protocol} {gp:protocol} {min,i:nat|i > min}
	(!session (self, s, forasc(min,i,sub)::gp) >> session (self, s, forasc(min,i-1,sub)::sub(i)::gp))
	: void 

fun foreach_dec_unroll
	{self,s:set} {sub: int->protocol} {gp:protocol} {i,max:nat|i < max}
	(!session (self, s, fordes(i,max,sub)::gp) >> session (self, s, fordes(i+1,max,sub)::sub(i)::gp))
	: void 

fun foreach_asc_done
	{self,s:set} {sub:int->protocol} {gp:protocol} {min:nat}
	(!session (self, s, forasc(min,min,sub)::gp) >> session (self, s, sub(min)::gp))
	: void 

fun foreach_dec_done
	{self,s:set} {sub: int->protocol} {gp:protocol} {max:nat}
	(!session (self, s, fordes(max,max,sub)::gp) >> session (self, s, sub(max)::gp))
	: void 

fun msend
	{self,s:set} {x,y:set|sub(s,x)*sub(s,y)*sub(self,x)*(cap(y,self)==empty_set())} {n:nat|mem(n,x)} {gp:protocol} {a:vt@ype}
	(!session (self, s, mmsg(x,y,a)::gp) >> session (self, s, mmsg(del(x,n),y,a)::gp), int n, set y, a)
	: void

fun mreceive
	{self,s:set} {x,y:set|sub(s,x)*sub(s,y)*(cap(x,self)==empty_set())*sub(self,y)} {n:nat|mem(n,y)} {gp:protocol} {a:vt@ype}
	(!session (self, s, mmsg(x,y,a)::gp) >> session (self, s, mmsg(x,del(y,n),a)::gp), set x, int n)
	: list a

fun skip_mmsg
	{self,s:set} {x,y:set|(cap(self,x)==empty_set()) * (cap(self,y)==empty_set())} {gp:protocol} {a:vt@ype}
	(!session (self, s, mmsg(x,y,a)::gp) >> session (self, s, gp))
	: void 

fun proj_mmsg 
	{self,s:set} {x,y:set} {gp:protocol} {a:vt@ype}
	(!session (self, s, mmsg(x,y,a)::gp) >> session (self, s, mmsg(cap(x,self), dif(y,self), a)::mmsg(dif(x,self), cap(y,self), a)::gp))
	: void





