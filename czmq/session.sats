

datasort process =
    | snd of (vt@ype, process)
    | rcv of (vt@ype, process)
    | frk of (process)
    | intc of (process, process)
    | extc of (process, process)
    | dual of process
    | nil of () 
    
absvtype session (process) = ptr

//fun {a:vt@ype} send {p:process} (!session (snd (a, p)) >> session p, a): void 
//fun {a:vt@ype} receive {p:process} (!session (rcv (a, p)) >> session p): a

fun {a:vt@ype} send {p:process} (!session (snd (a, p)) >> session p, a): void 
fun {a:vt@ype} send_dual {p:process} (!session (dual (rcv (a, p))) >> session (dual p), a): void 
fun {a:vt@ype} recv {p:process} (!session (rcv (a, p)) >> session p): a
fun {a:vt@ype} recv_dual {p:process} (!session (dual (snd (a, p))) >> session (dual p)): a
fun spawn {p:process} (!session (frk p)): session p


fun wait  (session nil): void
fun close (session nil): void


//symintr create
fun create_server {p:process} (session p -> void, address: string): void
fun create_client {p:process} (session p -> void, address: string): void
//overload create with create_server 
//overload create with create_client




