staload "sessions.sats"
#define :: pseq

#define C 1 
#define S 0

stadef ints = pfix (lam p => pbrch(C, pmsg(S,int)::p, pend C))

extern fun from (int): chan (C, ints)
extern fun filter (chan (C, ints), int -<cloref1> bool): chan (C, ints)
extern fun sieve (chan (C, ints)): chan (C, ints)


implement from (n) = let 
	fun server (chan: chan (S, ints), n: int): void = let 
		prval _ = recurse chan
		val choice = offer chan
	in 
		case+ choice of 
		| ~Left() => (send (chan, n); server (chan, n+1))
		| ~Right() => close chan
	end
in 
	create (llam (chan) => server (chan, n))
end



implement filter (chan, p) = let 
	fun get (chan: !chan(C, ints)): int = let 
		prval _ = recurse chan 
		val _ = choose (chan, Left ())
		val n = recv chan
	in 
		if p n
		then n 
		else get chan
	end

	fun server (out: chan(S,ints), inp: chan(C,ints)): void = let 
		prval _ = recurse out 
		val c = offer out 
	in 
		case+ c of 
		| ~Left() => (send (out, get inp); server (out, inp))
		| ~Right() => 
			let 
				val _ = close out
				prval _ = recurse inp
				val _ = choose (inp, Right())
			in
				close inp
			end
	end
in 
	create (llam (out) => server (out, chan))
end 


implement sieve (inp) = let 

	fun server (out: chan(S,ints), inp: chan(C,ints)): void = let 
		prval _ = recurse out
		val choice = offer out 
	in 
		case+ choice of 
		| ~Right() => let prval _ = recurse inp in (choose (inp, Right()); close inp; close out) end
		| ~Left() => 
			let 
				prval _ = recurse inp
				val _ = choose (inp, Left())
				val n = recv inp
				val _ = send (out, n)
			in 
				server (out, filter (inp, lam p => p mod n > 0))
			end
	end 
in 
	create (llam (out) => server (out, inp))
end


extern fun test (): void
implement test () = let
	val chan = sieve (from 2)

	fun loop (chan: chan(C,ints), n: int): void = 
		if n <= 0
		then let prval _ = recurse chan in (choose (chan, Right()); close chan) end
		else let prval _ = recurse chan in (choose (chan, Left()); println! (recv chan); loop (chan, n-1)) end
in 
	loop (chan, 20)
end




