


sortdef protocol = type 
//sortdef endpt = int 
//typedef endpt = int 

abstype cls () 
abstype msg (int, int, vt@ype)
abstype chse (int, int)
abstype seqs (type, type)

absprop PROJ (int, protocol, protocol)

abstype pfsession (protocol) = ptr 
datatype rtsession (protocol) = 
| rtcls (cls ()) of ()
| {p:protocol} rtskip (p) of ()
| {a:vt@ype} {x,y:int} rtmsg (msg (x, y, a)) of (int x, int y)
| {x:int} {n:int} rtchse (chse (x, n)) of (int x, int n)
| {p,q:protocol} rtseqs (seqs (p, q)) of (rtsession p, rtsession q)

typedef gsession (p:protocol, arity:int) = '{s = pfsession p, r = rtsession p, arity = int arity}
typedef session (self:int, p:protocol, arity:int) = '{s = pfsession p, r = rtsession p, self = int self, arity = int arity}


fun project {x:int|x >= 0} {gp:protocol} {arity:int|x < arity} (int x, gsession (gp, arity)): [p:protocol] (PROJ (x, gp, p) | session (x, p, arity))




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








