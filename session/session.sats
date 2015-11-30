





absvtype channel (type) = ptr
abstype name (type) = ptr 

abstype snd (vt@ype)
abstype rcv (vt@ype)
abstype cls ()
abstype wat ()

abstype seqs (type, type)
//abstype dual (type)
abstype rept (type)
abstype offr (type, type)
abstype chse (type, type)

abstype rqst (type)
abstype acpt (type)


#define :: seqs

absprop EQ   (type, type)  (* proposition: p1 == p2 *)
absprop DUAL (type, type)  (* proposition: the dual of p1 *)

praxi eq_intr: {p:type} () -> EQ (p, p)
praxi eq_comm: {p1,p2:type} EQ (p1, p2) -> EQ (p2, p1)
praxi eq_tran: {p1,p2,p3:type} (EQ (p1, p2), EQ (p2, p3)) -> EQ (p1, p3)


//praxi dual_intr:{p:type}() -> DUAL (p, dual p)
praxi dual_comm: {p1,p2:type} DUAL (p1, p2) -> DUAL (p2, p1)
praxi dual_elim: {p1,p2,p3:type} (DUAL (p1, p2), DUAL (p2, p3)) -> EQ (p1, p3)

praxi dual_base1: () -> DUAL (cls (), wat ())
praxi dual_base2: {a:vt@ype} () -> DUAL (snd a, rcv a)

praxi dual_ind1: {p1,p2,q1,q2:type} (DUAL (p1, q1), DUAL (p2, q2)) -> DUAL (offr (p1, p2), chse (q1, q2))
praxi dual_ind2: {p1,p2:type} DUAL (p1, p2) -> DUAL (rept p1, rept p2)
praxi dual_ind3: {p1,p2,q1,q2:type} (DUAL (p1, q1), DUAL (p2, q2)) -> DUAL (seqs (p1, p2), seqs (q1, q2))
//praxi dual_ind2: {p1,p2:type} DUAL (p1, p2) -> DUAL (rqst p1, acpt p2)

fun dualof {p1,p2:type} (DUAL (p1, p2) | !channel p1 >> channel p2): void  

fun make_name {p:type} (): name p
fun request {p1,p2:type} (DUAL (p1, p2) | name p1): channel p2
fun accept {p:type} (name p, channel p -<linclo1> void): void 

fun send    {a:vt@ype} {p:type} (!channel (snd a :: p) >> channel p, a): void 
fun receive {a:vt@ype} {p:type} (!channel (rcv a :: p) >> channel p): a 

fun unroll {p:type} (!channel (rept p) >> channel (p :: rept p)): void 

fun offer      {p,q:type} (channel (offr (p, q)), channel p -<linclo1> void, channel q -<linclo1> void): void 
fun choose_fst {p,q:type} (!channel (chse (p, q)) >> channel p): void 
fun choose_snd {p,q:type} (!channel (chse (p, q)) >> channel q): void 

fun close (channel (cls ())): void 
fun wait  (channel (wat ())): void 



////
fun make_name {p:type} (string): name (acpt p)
fun 

fun accept {p:type} (name (acpt p)): channel p 
////
//praxi dual_elim {p:type} (): EQ (dual (dual p), p)
//praxi dual_intr_0 {p1,zunp2:type} (EQ (p1, p2)): EQ (dual p1, dual p2) 
//praxi dual_intr_1

fun dual_intr {p1}

fun {a:vt@ype} {p1,p2:type} (DUAL (p1, p2)): DUAL (snd a :: p1, rcv a :: p2)




//fun dualof0 {a:t@ype} {p:type} (!channel (snd a :: p) >> channel (rcv a :: dual p)): void
//fun dualof1 {a:t@ype} {p:type} (!channel (rcv a :: p) >> channel (snd a :: dual p)): void 

//symintr dualof 
//overload dualof with dualof0
//overload dualof with dualof1









////
abstype name (vt@ype) = ptr 

datasort protocol =
    | nil of ()
    | cons of (protocol, protocol)
    | snd of (vt@ype)
    | rcv of (vt@ype)
//    | rpt of (protocol)
//    | off of (protocol, protocol)
//    | cho of (protocol, protocol)
//    | req of (protocol)
//    | acc of (protocol)
    | dual of (protocol)

#define :: cons
    
//absvtype channel (protocol) = ptr 

datavtype channel (p:protocol) = 
| nil (nil) of ()
| {a:vt@ype} snd (snd a :: p) of (channel p)
| {a:vt@ype} rcv (rcv a :: p) of (channel p)
| dual (dual p) of (channel p)


fun send {a:vt@ype} {p:protocol} (!channel (snd a :: p) >> channel p, a): void

////

//fun {a:vt@ype} send {p:protocol} (!session (snd (a, p)) >> session p, a): void 
//fun {a:vt@ype} receive {p:protocol} (!session (rcv (a, p)) >> session p): a

symintr send 
symintr recv 

//fun send_server {p:protocol} (!session (snd (string, p)) >> session p, string): void 
//fun receive_server {p:protocol} (!session (rcv (string, p)) >> session p): string
//fun send_client {p:protocol} (!session (dual (rcv (string, p))) >> session (dual p), string): void 
//fun receive_client {p:protocol} (!session (dual (snd (string, p))) >> session (dual p)): string

//overload send with send_server
//overload send with send_client 
//overload receive with receive_server
//overload receive with receive_client

//fun wait (session nil): void 
//fun close (session nil): void


//symintr create
//fun create_server {p:protocol} (session (p) -> void, address: string): void
//fun create_client {p:protocol} (session (p) -> void, address: string): void
//fun create_client {p:protocol} (session (dual p) -> void, address: string): void

//overload create with create_server 
//overload create with create_client

dataprop EQ (protocol, protocol) = 
| {p:protocol}                EQ_REFLC (p, p)						 	      of ()
| {p1,p2:protocol}            EQ_COMMU (p1, p2)           of EQ (p2, p1)
| {p1,p2,p3:protocol}         EQ_TRANS (p1, p3)                               of (EQ (p1, p2), EQ (p2, p3))
|                             EQ_IND_0 (dual nil, nil)                        of ()
| {a:vt@ype} {p1,p2:protocol} EQ_IND_1 (dual (snd (a, p1)), rcv (a, dual p2)) of EQ (p1, p2)
| {a:vt@ype} {p1,p2:protocol} EQ_IND_2 (dual (rcv (a, p1)), snd (a, dual p2)) of EQ (p1, p2)
//| {p1,p2:protocol}          EQ_IND_3 (dual (req p1), acc (p2))              of EQ (p1, p2)
| {p1,p2:protocol}            EQ_DUAL  (dual (dual p1), p2)                   of EQ (p1, p2)




fun normalize {p1:protocol} (!channel p1 >> channel p2): #[p2:protocol] (EQ (p1, p2) | void)
////
datasort name (protocol) = 
| req (protocol) of protocol
| acc (protocol) of protocol

fun make_name {p:protocol} (string): name (channel p)

fun request {p:protocol} (name (channel p), channel (dual p) -<linclo1> void): void
fun accept {p:protocol} (name (channel p), channel p -<linclo1> void): void





//fun create {p:protocol} (): channel p
//fun connect {p:protocol} (endpoint: string): channel (dual p)

fun send_1 {p:protocol} {a:vt@ype} (!channel (snd (a, p)) >> channel p, a): void 
fun send_2 {p:protocol} {a:vt@ype} (!channel (dual (rcv (a, p))) >> channel (dual p)): a 
overload send with send_1
overload send with send_2

fun recv_1 {p:protocol} {a:vt@ype} (!channel (rcv (a, p)) >> channel p): a 
fun recv_2 {p:protocol} {a:vt@ype} (!channel (dual (snd (a, p))) >> channel (dual p)): a 
overload recv with recv_1 
overload recv with recv_2  

fun close (channel (dual nil)): void 
fun wait (channel nil): void 



//fun receive {p:protocol} {a:vt@ype} (!channel p): a 

////
cons (

////

datavtype zmq_channel (session


implement create {p:type} (server)


    val ctx = zmq_contex_new()
    val socket = zmq_socket()
    val _ = zmq_bind (socket)
    
in 
    asdlkajsdlkj
end


typedef serverproto = rpt (int) :: snd (string) :: nil 
typedef clientproto = snd (int) :: rcv (string) :: nil 

fun server {p:type} (s: session (bind: string):



datavtype protocol = 
    | Inactive of ()
    | Receive of (a:vt@ype, protocol)
    | Send of (a:vt@ype, protocol)
    
absvtype session (protocol)

fun {a:vt@ype} send (!session (Send (a, p)