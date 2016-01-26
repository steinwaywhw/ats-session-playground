




absprop PROJ (int, type, type)

typedef ep (n:int) = int n 

abstype cls ()
abstype msg (t@ype, t@ype, vt@ype)
abstype seqs (type, type) 
#define :: seqs

abstype name (type) = ptr

absvtype prsession (type) = ptr 
datavtype rtsession (type) = 
| {a:type} rtskip (a) of ()
| rtcls (cls ()) of () 
| {x,y:int} {a:vt@ype} rtmsg (msg (ep x, ep y, a)) of (ep x, ep y)
| {a,b:type} rtseqs (seqs (a, b)) of (rtsession a, rtsession b)

vtypedef gsession (s:type) = '{p = prsession s, r = rtsession s}
vtypedef session (ep:t@ype, s:type) = '{self = ep, p = prsession s, r = rtsession s}

fun send {x,y:int} {a:vt@ype} {s:type} (!session (ep x, msg (ep x, ep y, a) :: s) >> session (ep x, s), ep y, a): void
fun recv {x,y:int} {a:vt@ype} {s:type} (!session (ep x, msg (ep y, ep x, a) :: s) >> session (ep x, s), ep y): a

fun accpet {x:int} {s:type} (name s, gsession s, ep x): [ss:type] (PROJ (x, s, ss) | session (ep x, ss))
fun request {x:int} {s:type} (name s, gsession s, ep x): [ss:type] (PROJ (x, s, ss) | session (ep x, ss))
fun project {x:int} {s:type} (gsession s, ep x): [ss:type] (PROJ (x, s, ss) | session (ep x, ss))





