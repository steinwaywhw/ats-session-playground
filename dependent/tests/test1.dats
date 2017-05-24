

staload "../session.sats"
#define :: pseq

stadef rpt (n:int) = pfix2 (lam (p:int->stype) => lam (n:int) => pite (n>0, pmsg(1, char)::p(n-1), pend(1)), n)
vtypedef chan (r:int) = chan (r, pquan (1, lam (n:int) => pmsg(1,int(n)) :: rpt(n)))

extern fun test1_server (chan (0)): void
extern fun test1_client (chan (1)): void

implement test1_server (chan) = () where {
    val _ = exify chan
    val n = recv chan

    val _ = assertloc (n > 0)

    fun loop {p:stype} {n:nat|n > 0} (chan: !chan(0,rpt(n)) >> chan(0,rpt(0)), n: int n): void = 
        if n > 0
        then 
            let 
                prval _ = recurse2 chan
                prval _ = itet chan
                val c = recv chan 
                val _ = print_char c 
            in 
                if n-1 > 0 then loop (chan, n-1) else ()
            end

    val _ = loop (chan, n) 
    prval _ = recurse2 chan
    prval _ = itef chan
    val _ = wait chan
}


implement test1_client (chan) = () where {
    val _ = unify chan
    val n = 10
    val _ = send (chan, n)

    fun loop {p:stype} {n:nat|n > 0} (chan: !chan(1,rpt(n)) >> chan(1,rpt(0)), n: int n): void = 
        if n > 0
        then 
            let 
                prval _ = recurse2 chan
                prval _ = itet chan
                val _ = send (chan, 'a')
            in 
                if n-1>0 then loop (chan, n-1) else ()
            end 

    val _ = loop (chan, n)
    prval _ = recurse2 chan 
    prval _ = itef chan
    val _ = close chan

}

implement main0 () = () where {
    val chan = create {1,0} (llam chan => test1_server (chan))
    val _ = test1_client chan
}

