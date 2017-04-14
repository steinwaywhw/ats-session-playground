staload "sessions.sats"
staload UN = "prelude/SATS/unsafe.sats"

#define C 1
#define S 0


stadef fp (a:t@ype) = lam (p:int->protocol):int->protocol => lam (n:int):protocol => pite (n>0, pbrch(C, pmsg(C,a)::p(n+1), pmsg(S,a)::p(n-1)), pmsg(C,a)::p(n+1))
stadef queue (a:t@ype) = pfix2 (fp a)


extern fun empty {a:t@ype} (): chan(C, (queue a) 0)
extern fun elem  {a:t@ype} {n:nat} (chan(C, (queue a) n), a): chan(C, (queue a) (n+1))

implement empty {a} () = let 
	fun server (out: chan(S, (queue a) 0)): void = let 
		val _ = recurse2 {S} {fp a} {0} out 
		val _ = ite_false out
		val x = recv out 
		val tail = empty {a} ()
		val q = elem {a} {0} (tail, x)
	in 	
		cut (q, out)
	end
in 
	create (llam out => server out)
end

implement elem {a} {n} (queue, e)  = let 
	fun server (out: chan(S, (queue a) (n+1)), inp: chan(C, (queue a) n)): void = let 
		val _ = recurse2 {S} {fp a} {n+1} out 
		val _ = ite_true out 
		val c = offer out
	in 
		case+ c of 
		| ~Right() => (send (out, e); cut {S} {(queue a) n} (out, inp))
		| ~Left() => 
			let 
				val y = recv out 
				val _ = choose (inp, Left())
				val _ = send (inp, y)
			in 
				server (out, inp)
			end
	end
in 
	create (llam out => server (out, queue))
end


implement main0 () = () where {
	val queue = empty {int} ()
	val _ = recurse2 {C} {fp int} {0} queue 
	val _ = ite_false queue 
	val _ = send (queue, 1)

	val _ = recurse2 {C} {fp int} {0+1} queue 
	

	val _ = $UN.cast2void queue

}

////

implement elem {a} (inp, x) = let 
	fun server (out: chan(S,queue(a)), inp: chan(C,queue(a))): void = let 
		val _ = recurse out
		val c = offer out
	in 
		case+ c of 
		| ~Left() => 
			let
				val y = recv out
				val _ = recurse inp
				val _ = choose (inp, Left())
				val _ = send (inp, y) 
			in 
				server (out, inp)
			end
		| ~Right() => 
			let 
				val _ = choose (out, Right())
				val _ = send (out, x)
			in 
				cut (out, inp)
			end
	end
in 
	create (llam out => server (out, inp))
end



