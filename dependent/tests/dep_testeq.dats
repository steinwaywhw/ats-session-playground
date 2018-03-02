
staload "../session.sats"


stadef proto = pquan(0, lam (m:int) => 
			       pquan(0, lam (n:int) => 
			           pmsg(0,int(m))::pmsg(0,int(n))::pmsg(1,bool(m==n))::pend(0)))

extern fun server (chan (1, proto)): void
extern fun client (chan (0, proto)): void


implement server (ch) = let 
    prval _ = exify (ch)
    prval _ = exify (ch)
	val a = recv (ch)
	val b = recv (ch)
	val _ = send (ch, a = b)
//	val _ = send (ch, ~(a != b))
in 
	wait ch 
end

implement client (ch) = let 
	prval _ = unify (ch)
	prval _ = unify (ch)
	val _ = send (ch, 1) 
	val _ = send (ch, 1) 
	val c = recv (ch)
	val _ = println! c
in 
	close ch 
end


extern fun test (): void 
implement test () = let 
	val c = create {0,1} (llam s => server s)
in 
	client c
end