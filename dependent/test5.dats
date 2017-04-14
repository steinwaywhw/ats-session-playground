staload "sessions.sats"

#define C 1
#define S 0


stadef queue (a:t@ype) = pfix (lam p => pbrch(C, pmsg(C,a)::p, pbrch(S, pend(S), pmsg(S,a)::p)))

extern fun empty {a:t@ype} (): chan(C,queue a)
extern fun elem  {a:t@ype} (chan(C,queue a), a): chan(C,queue a)


implement elem {a} (inp, x) = let 
	fun server (out: chan(S,queue(a)), inp: chan(C,queue(a))): void = let 
		prval _ = recurse out
		val c = offer out
	in 
		case+ c of 
		| ~Left() => 
			let
				val y = recv out
				prval _ = recurse inp
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


implement empty {a} () = let 
	fun server {a:t@ype} (out: chan(S,queue(a))): void = let 
		prval _ = recurse out 
		val c = offer out 
	in 	
		case+ c of 
		| ~Right() => (choose(out, Left()); close out)
		| ~Left() => 
			let 
				val x = recv out 
				val tail = empty {a} ()
				val q = elem {a} (tail, x)
			in 
				cut (q, out)
			end
	end

in 
	create (llam out => server {a} out)
end


extern fun test (): void
implement test () = let 
	val queue = empty {int} ()

	fun enq {a:t@ype} (chan: !chan(C,queue(a)), e:a): void = let 
		prval _ = recurse chan
		val _ = choose (chan, Left())
		val _ = send (chan, e)
	in 
	end

	fun printall (chan: chan(C,queue(int))): void = let 
		prval _ = recurse chan 
		val _ = choose (chan, Right())
		val choice = offer chan
	in 
		case+ choice of 
		| ~Left() => (println! ("nil"); close chan)
		| ~Right() => (println! (recv chan); printall chan)
	end

    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,4); enq{int}(queue,5); enq{int}(queue,6))
    val _ = (enq{int}(queue,7); enq{int}(queue,8); enq{int}(queue,9))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,3))
    val _ = (enq{int}(queue,1); enq{int}(queue,2); enq{int}(queue,300))

in 
	printall queue
end