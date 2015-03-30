

datasort process =
    | snd of (vt@ype, process)
    | rcv of (vt@ype, process)
    | dual of process
    | nil of () 
    
absvtype session (process)

fun {a:vt@ype} send {p:process} (!session (snd (a, p)) >> session p, a): void 
fun {a:vt@ype} receive {p:process} (!session (rcv (a, p)) >> session p): a

fun wait (session nil): void 
fun close (session nil): void
fun create {p:process} (session (p) -<lincloptr1> void): session (dual p)
fun connect {p:process} (session (p) -<lincloptr1> void): session (dual p)

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



datavtype process = 
    | Inactive of ()
    | Receive of (a:vt@ype, process)
    | Send of (a:vt@ype, process)
    
absvtype session (process)

fun {a:vt@ype} send (!session (Send (a, p)