

datasort process =
    | snd of (vt@ype, process)
    | rcv of (vt@ype, process)
    | dual of process
    | nil of () 
    
absvtype session (process) = ptr

//fun {a:vt@ype} send {p:process} (!session (snd (a, p)) >> session p, a): void 
//fun {a:vt@ype} receive {p:process} (!session (rcv (a, p)) >> session p): a

symintr send 
symintr receive 

fun send_server {p:process} (!session (snd (string, p)) >> session p, string): void 
fun receive_server {p:process} (!session (rcv (string, p)) >> session p): string
//fun send_client {p:process} (!session (dual (rcv (string, p))) >> session (dual p), string): void 
//fun receive_client {p:process} (!session (dual (snd (string, p))) >> session (dual p)): string

overload send with send_server
//overload send with send_client 
overload receive with receive_server
//overload receive with receive_client

fun wait (session nil): void 
fun close (session nil): void


symintr create
fun create_server {p:process} (session (p) -> void, address: string): void
fun create_client {p:process} (session (p) -> void, address: string): void
//fun create_client {p:process} (session (dual p) -> void, address: string): void

overload create with create_server 
overload create with create_client




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