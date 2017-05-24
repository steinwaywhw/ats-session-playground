

staload "sessions.sats"
#define :: pseq

vtypedef chan (r:int) = chan (r, pquan (1, lam (n:int) => pmsg(1,int(n)) :: prpt(n,pmsg(1,char)) :: pend(1)))

extern fun test1_server (chan (0)): void
extern fun test1_client (chan (1)): void

implement test1_server (chan) = () where {
    val _ = exify chan
    val n = recv chan

    val _ = assertloc (n >= 0)

    fun loop {p:protocol} {n:nat} (chan: !chan(0,prpt(n,pmsg(1,char))::p) >> chan(0,p), n: int n): void = 
        if n = 0
        then unroll0 chan 
        else 
            let 
                val _ = unroll1 chan 
                val c = recv chan 
                val _ = print_char c 
            in 
                loop (chan, n-1) 
            end

    val _ = loop (chan, n) 
    val _ = wait chan
}

implement test1_client (chan) = () where {
    val _ = unify chan
    val n = 10
    val _ = send (chan, n)

    fun loop {p:protocol} {n:nat} (chan: !chan(1,prpt(n,pmsg(1,char))::p) >> chan(1,p), n: int n): void = 
        if n = 0
        then unroll0 chan
        else 
            let 
                val _ = unroll1 chan 
                val _ = send (chan, 'a')
            in 
                loop (chan, n-1) 
            end 

    val _ = loop (chan, n)
    val _ = close chan

}

implement main0 () = () where {
    val chan = create {1} (llam chan => test1_server (chan))
    val _ = test1_client chan
}

