


(* protocol *)
sortdef protocol = type

(* binary role *)
sortdef role = {n:int|n==0||n==1}

(* atomics *)
stacst msg: (int, vt@ype) -> protocol 
stacst nil: int -> protocol 
stacst seq: (protocol, protocol) -> protocol

#define :: seq

(* connectives *)
stacst addi: (int, protocol, protocol) -> protocol // additives: oplus, amp
stacst mult: (int, protocol, protocol) -> protocol // multiplicatives: tensor, parr

(* type constructor *)
absvtype chan (int, protocol)

(* axiom *)
fun create {r1,r2:role|r1 != r2} {p:protocol} (chan(r1,p) -<lincloptr1> void): chan(r2,p)

(* atomics *)
fun send  {r:role} {p:protocol} {v:vt@ype} (!chan(r,msg(r,v)::p) >> chan(r,p), v): void
fun recv  {r:role} {p:protocol} {v:vt@ype} (!chan(r,msg(1-r,v)::p) >> chan(r,p)): v 
fun wait  {r:role} (chan(r,nil(1-r))): void 
fun close {r:role} (chan(r,nil r)): void

(* additive connectives *)
datavtype choice (protocol, p:protocol, q:protocol) = 
| Left  (p,p,q) 
| Right (q,p,q)

(* In a cut, there is one oplus (choose) with many amp (offer)
   As a user, they are holding one amp and many oplus. 
   Then users themselves are one oplus and many amp.
*)
fun amp   {r,r0:role|r0 != r} {p,q:protocol} (!chan(r,addi(r0,p,q)) >> chan(r,s)): #[s:protocol] choice (s,p,q)
fun oplus {r,r0:role|r0==r} {p,q,s:protocol} (!chan(r,addi(r0,p,q)) >> chan(r,s), choice (s,p,q)): void


(* multiplicative connectives *)
(* In a cut, there is one parr with many tensor
   As a user, they are holding one tensor and many parr
   Then users themselves are one parr and many tensor
*)
fun tensor {r,r0:role|r0 != r} {p,q:protocol} (chan(r,mult(r0,p,q)), chan(r,p) -<lincloptr1> void, chan(r,q) -<lincloptr1> void): void
fun parr   {r,r0:role|r0==r} {p,q:protocol}   (chan(r,mult(r0,p,q))): @(chan(r,p), chan(r,q))

(* cut *)
fun cut    {r1,r2:role|r1 != r2} {p:protocol} (chan(r1,p), chan(r2,p)): void



