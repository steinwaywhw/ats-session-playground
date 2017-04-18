
staload "sessions.sats"


stadef proto = pquan2(0, lam (s:stype):stype => pmsg(1, chan(1,s)) :: s)
stadef subproto = pmsg(0, string) :: pend(0)


extern fun server (!chan(0,proto) >> chan(0,s)): #[s:stype] chan(1,s)
extern fun client (chan(1,proto)): void


implement server (ch) = let 
	prval _ = exify2 ch 
	val ch2 = recv ch
in 
	ch2
end


implement client (ch1) = let 
	val ch2 = create {1,0} {subproto} (llam ch2 => (send (ch2, "hello"); close ch2))
	prval _ = unify2 ch1 
	val _ = send {1,1} (ch1, ch2)
	val str = recv ch1
	val _ = println! str
in 
	wait ch1
end

extern fun test (): void 
implement test () = let
	val ch = create {1,0} {proto} (llam ch1 => let val ch2 = server ch1 in cut (ch1, ch2) end)
in 
	client (ch)
end