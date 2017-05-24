
staload "../session.sats"

#define S 0
#define C 1


stadef cloud = pquan2(C, lam (x:stype):stype => pmsg(C, chan(S,x)->void) :: prep(C,x))



extern fun cloudserver (chan (S, cloud)): void
implement cloudserver (ch) = let 
	val [x:stype] ch = exify2 ch 
	val f = recv {S,C} {prep(C,x)} {chan(S,x)->void} ch 
	prval _ = service ch

	fun loop {x:stype} (ch:chan(S,pfix(lam s=>pbrch(C,pmsg(1-1,chan(C,x))::s,pend(C)))), f:chan(S,x)->void): void = let 
		prval _ = recurse ch 
		val choice = offer ch
	in 
		case+ choice of 
		| ~Right() => wait ch 
		| ~Left() => 
			let 
				val ep = create {C,S} {x} (llam ch => f ch)
				val _ = send (ch, ep)
			in 
				loop {x} (ch, f)
			end 
	end
in 
	loop {x} (ch, f)
end


stadef sub = pmsg(C,string)::pend(C)

extern fun client (chan(C, cloud)): void
implement client (ch) = let 
	
	
	fun echo (c:chan(S,sub)): void = (println!(recv c); wait c)

	prval _ = unify2 ch
	val _ = send (ch, echo)
	prval _ = service ch 

	fun loop (ch:chan(C,pfix(lam s=>pbrch(C,pmsg(1-1,chan(C,sub))::s,pend(C)))), n:int): void = let 
		prval _ = recurse ch 
	in 
		if n <= 0
		then (choose(ch,Right()); close ch)
		else 
			let 
				val _ = choose(ch,Left())
				val ep = recv ch 
				val _ = send (ep, "hello")
				val _ = close ep 
			in 
				loop (ch, n-1)
			end
	end
in 
	loop (ch, 10)
end


extern fun test (): void 
implement test () = let 
	val ch = create {C,S} {cloud} (llam ch => cloudserver ch)
in 
	client ch
end