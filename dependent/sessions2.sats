#define ATS_EXTERN_PREFIX "libsession_"

sortdef role = {a:int|a==0||a==1}

//datasort protocol = 
//| pmsg  of (int, vt@ype)
//| prpt  of (int, protocol)
//| pbrch of (int, protocol, protocol)
//| pend  of (int)
//| pseq  of (protocol, protocol)
//| pquan of (int, int -> protocol)
//| pfix  of (protocol -> protocol)

sortdef protocol = type
abstype pmsg (int, vt@ype)
abstype prpt (int, protocol)
abstype pbrch (int, protocol, protocol)
abstype pend (int)
abstype pseq (protocol, protocol)
abstype pquan (int, int -> protocol)
abstype pfix (protocol -> protocol)

#define :: pseq

absvtype chan (int, protocol)

fun create {r:role} {p:protocol} (chan (1-r, p) -<lincloptr1> void): chan (r, p)
fun send   {r:role} {p:protocol} {a:vt@ype} (!chan (r, pmsg(r,a) :: p) >> chan (r, p), a): void
fun recv   {r:role} {p:protocol} {a:vt@ype} (!chan (r, pmsg(1-r,a) :: p) >> chan (r, p)): a
fun close  {r:role} {p:protocol} (chan (r, pend r)): void
fun wait   {r:role} {p:protocol} (chan (r, pend (1-r))): void


datavtype choice (protocol, p:protocol, q:protocol) = 
| Left  (p, p, q) of ()
| Right (q, p, q) of ()


fun offer  {r:role} {p1,p2:protocol} (!chan (r, pbrch(1-r,p1,p2)) >> chan (r, p)): #[p:protocol] choice (p, p1, p2)
fun choose {r:role} {p,p1,p2:protocol} (!chan (r, pbrch(r,p1,p2)) >> chan (r, p), choice (p, p1, p2)): void

fun unroll1 {r:role} {p1,p2:protocol} {n:int|n>0} (!chan (r, prpt(n,p1) :: p2) >> chan (r, p1 :: prpt(n-1,p1) :: p2)): void
fun unroll0 {r:role} {p1,p2:protocol} (!chan (r, prpt(0,p1) :: p2) >> chan (r, p2)): void

fun unify {r:role} {p:protocol} {fp:int->protocol} (!chan (r, pquan (r, fp)) >> {n:int} chan (r, fp(n))): void
fun exify {r:role} {p:protocol} {fp:int->protocol} (!chan (r, pquan (1-r, fp)) >> [n:int] chan (r, fp(n))): void

fun recurse {r:role} {p:protocol} {fp:protocol->protocol} (!chan (r, pfix (fp)) >> chan (r, fp (pfix (fp)))): void