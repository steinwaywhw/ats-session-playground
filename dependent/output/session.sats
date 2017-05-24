
#define ATS_EXTERN_PREFIX "libsession__"

sortdef role = {a:int|a==0||a==1}

datasort stype = 
| pmsg   of (int, vt@ype) (* used with pseq for syntax brevity *)
| pseq   of (stype, stype)
| pbrch  of (int, stype, stype)
| pend   of (int)
| pquan  of (int, int -> stype)
| pquan2 of (int, stype -> stype)
| pfix   of (stype -> stype)
| pite   of (bool, stype, stype)
| pfix2  of ((int -> stype) -> (int -> stype), int)
| prep   of (int, stype)

(* used for syntax brevity *)
#define :: pseq

(* channel *)
absvtype chan (int, stype) = ptr

fun create {r1,r2:role} {p:stype} {r1 != r2} (chan(r2,p) -<lincloptr1> void): chan(r1,p) = "mac#%"

fun send   {r,r0:role}  {p:stype} {a:vt@ype} {r0 == r}  (!chan(r, pmsg(r0,a)::p) >> chan(r,p), a): void = "mac#%"
fun recv   {r,r0:role}  {p:stype} {a:vt@ype} {r0 != r}  (!chan(r, pmsg(r0,a)::p) >> chan(r,p)): a = "mac#%"

fun close  {r,r0:role}  {p:stype} {r0 == r} (chan(r, pend r0)): void = "mac#%"
fun wait   {r,r0:role}  {p:stype} {r0 != r} (chan(r, pend r0)): void = "mac#%"

fun cut {r1,r2:role} {p:stype} {r1 != r2} (chan(r1,p), chan(r2,p)): void = "mac#%"


prfun service {r,r0:role} {p:stype} (!chan(r,prep(r0,p)) >> chan(r,pfix(lam s=>pbrch(r0,pmsg(1-r0,chan(r0,p))::s,pend(r0))))): void

//prfun request {r,r0:role} {p:stype} {r == r0} (!chan(r,prep(r0,p)) >> chan(r,pfix(lam s=>pbrch(r0,pmsg(1-r,chan(r0,p))::s,pend(r0))))): void
//prfun accept  {r,r0:role} {p:stype} {r != r0} (!chan(r,prep(r0,p)) >> chan(r,pfix(lam s=>pbrch(r0,pmsg(r,chan(r0,p))::s,pend(r0))))): void


datavtype choice (stype, p:stype, q:stype) = 
| Left  (p, p, q) of ()
| Right (q, p, q) of ()

fun offer  {r,r0:role} {p1,p2:stype}   {r0 != r} (!chan(r, pbrch(r0,p1,p2)) >> chan(r,p)): #[p:stype] choice(p,p1,p2) = "mac#%"
fun choose {r,r0:role} {p,p1,p2:stype} {r0 == r} (!chan(r, pbrch(r0,p1,p2)) >> chan(r,p), choice(p,p1,p2)): void = "mac#%"

prfun itet {r:role} {pt,pf:stype} (!chan(r, pite(true,pt,pf))  >> chan(r,pt)): void
prfun itef {r:role} {pt,pf:stype} (!chan(r, pite(false,pt,pf)) >> chan(r,pf)): void

prfun exify {r,r0:role} {fp:int->stype} {r0 != r} (!chan(r, pquan(r0,fp)) >> [n:int] chan (r,fp(n))): void
prfun unify {r,r0:role} {fp:int->stype} {r0 == r} (!chan(r, pquan(r0,fp)) >> {n:int} chan (r,fp(n))): void
castfn exify2 {r,r0:role} {fp:stype->stype} {r0 != r} (chan(r, pquan2(r0,fp))): [s:stype] chan (r,fp(s))
prfun unify2 {r,r0:role} {fp:stype->stype} {r0 == r} (!chan(r, pquan2(r0,fp)) >> {s:stype} chan (r,fp(s))): void

prfun recurse  {r:role} {p:stype} {fp:stype->stype} (!chan (r, pfix(fp)) >> chan (r, fp(pfix(fp)))): void
prfun recurse2 {r:role} {fp:(int->stype)->(int->stype)} {n:int} (!chan (r, pfix2(fp,n)) >> chan(r, fp(lam n=>pfix2(fp,n))(n))): void


