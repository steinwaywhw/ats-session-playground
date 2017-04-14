
staload "sessions.sats"


vtypedef chan(r:int) = chan(r, pmsg(0,int)::pmsg(0,int)::pmsg(0,int)::pend(0))


extern fun server (chan 0): void
extern fun client (chan 1): void


implement server (ch) = let 
	val _ = send (ch, 1)
	val _ = send (ch, 2)
	val _ = send (ch, 3)
in 
	close ch 
end

implement client (ch) = let 
	val _ = recv ch 
	val _ = recv ch 
	val _ = recv ch 
in 
	close ch 
end


extern fun test (): void 
implement test () = let 
	val c = create {1,0} (llam s => server s)
	val s = create {0,1} (llam c => client c)
in 
	cut (s, c)
end