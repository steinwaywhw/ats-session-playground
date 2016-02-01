
sortdef protocol = type 

abstype cls () 
abstype skip ()
abstype msg (int, int, vt@ype)
abstype chse (int, int)
abstype seqs (type, type)

#define :: seqs

sortdef endpt    = nat  // for normal endpoints
sortdef endpt_bc = {n: int | n >= ~1} // for normal and broadcast endpoints

//absprop PROJ (int, protocol, protocol) // (endpt, global protocol, local protocol)

absvtype pfsession (protocol) = ptr 

//datavtype rtsession (protocol, arity:int) = 
//| rtcls (cls (), arity) of ()
//| rtskip (skip (), arity) of ()
//| {a:vt@ype} {x:endpt|x < arity} {y:endpt_bc|y < arity} rtmsg (msg (x, y, a), arity) of (int x, int y)
//| {x:endpt|x < arity} {n:nat} rtchse (chse (x, n), arity) of (int x, int n)
//| {p,q:protocol} rtseqs (seqs (p, q), arity) of (rtsession (p, arity), rtsession (q, arity))


dataprop PROJ (self:int, protocol, protocol) = 
(* basis *)
| proj_skip (self, skip(), skip())
| proj_cls (self, cls(), cls())
(* message *)
| {x:int} {a:vt@ype} proj_msg_from (self, msg(self,x,a), msg(self,x,a))
| {x:int} {a:vt@ype} proj_msg_to   (self, msg(x,self,a), msg(x,self,a))
(* broadcast *)
| {x:nat|x != self} {a:vt@ype} proj_msg_broadcast (self, msg(x,~1,a), msg(x,self,a))
(* choose *)
| {x:nat} {c:int} proj_chse (self, chse (x, c), chse (x, c))
(* skip *)
| {x,y:nat|self != x && self != y} {a:vt@ype} proj_msg_skip (self, msg(x,y,a), skip())
(* seqs *)
| {p,pp,q,qq:protocol} proj_seqs (self, p::q, pp::qq) of (PROJ(self,p,pp), PROJ(self,q,qq))
| {p,q,qq:protocol}    proj_seqs_skipp (self, p::q, qq) of (PROJ(self,p,skip()), PROJ(self,q,qq))
| {p,pp,q:protocol}	   proj_seqs_skipq (self, p::q, pp) of (PROJ(self,p,pp), PROJ(self,q,skip()))


datavtype rtsession (protocol) = 
| rtcls (cls ()) of ()
| rtskip (skip ()) of ()
| {a:vt@ype} {x:endpt} {y:endpt_bc} rtmsg (msg (x, y, a)) of (int x, int y)
| {x:endpt} {n:nat} rtchse (chse (x, n)) of (int x, int n)
| {p,q:protocol} rtseqs (seqs (p, q)) of (rtsession p, rtsession q)

//vtypedef rtsession (p:protocol, arity:int) = rtsession p 



//typedef gsession (p:protocol, arity:int) = '{s = pfsession p, r = rtsession p, arity = int arity}
//typedef session (self:int, p:protocol, arity:int) = '{s = pfsession p, r = rtsession p, self = int self, arity = int arity}

//vtypedef session (self:endpt, p:protocol, arity:nat) = pfsession (p, arity)

//fun request {arity:nat} {x:endpt|x<arity} {gp:protocol} (int x, rtsession (gp, arity), int arity): [p:protocol] (PROJ (x, gp, p) | session (x, p, arity))
//fun accpet  {arity:nat} {x:endpt|x<arity} {gp:protocol} (int x, rtsession (gp, arity), int arity): [p:protocol] (PROJ (x, gp, p) | session (x, p, arity))

//fun validate {(rtsession (p, a), rtsessino (q, b)): void

vtypedef session (self:int, p:protocol) = @{session = pfsession p, rt = rtsession p, self = int self}

abstype name (protocol) = ptr 
fun make_name {gp:protocol} (string): name gp

fun request {x:endpt} {gp,p:protocol} (PROJ (x, gp, p) | name gp, int x, rtsession gp): session (x, p)
fun accept  {x:endpt} {gp,p:protocol} (PROJ (x, gp, p) | name gp, int x, rtsession gp, session (x, p) -<linclo1> void): void


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

fun project {x:endpt} {gp:protocol} (int x, rtsession gp): [p:protocol] (PROJ (x, gp, p) | rtsession p)


fun is_equal {p,q:protocol} (!rtsession p, !rtsession q): bool 

fun send {x:nat} {y:int} {p:protocol} {a:vt@ype} (!session (x, msg(x,y,a) :: p) >> session (x, p), a): void 
fun receive {x:nat} {y:int} {p:protocol} {a:vt@ype} (!session (x, msg(y,x,a) :: p) >> session (x, p)): a
fun close {x:nat} (session (x, cls())): void 
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








