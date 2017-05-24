staload "../session.sats"
staload UN = "prelude/SATS/unsafe.sats"

#define C 1
#define S 0

stadef fp (a:t@ype) = 
	lam (p:int->stype):int->stype => 
		lam (n:int):stype => pbrch(C, pmsg(C,a)::p(n+1), pite(n>0, pmsg(S,a)::p(n-1), pend(0)))

stadef queue (a:t@ype, n:int) = pfix2 (fp a, n)


extern fun empty {a:t@ype} (): chan(C, queue(a,0))
extern fun elem  {a:t@ype} {n:nat} (chan(C, queue(a,n)), a): chan(C, queue(a,n+1))

implement empty {a} () = let 
	fun server (out: chan(S, queue(a,0))): void = let 
		prval _ = recurse2 out 
		val choice = offer out
	in 
		case+ choice of 
		| ~Right () => 	
			let 
				prval _ = itef out
			in 
				close out
			end
		| ~Left ()  => 
			let 
				val x = recv out 
				val tail = empty {a} ()
				val inp = elem {a} (tail, x)
			in 
				cut (inp, out)
			end
	end

in 
	create (llam out => server out)
end


implement elem {a} {n} (queue, e)  = let 
	fun server {n:nat} (out: chan(S, queue(a,n+1)), inp: chan(C, queue(a,n))): void = let 
		prval _ = recurse2 out 
		val choice = offer out
	in 
		case+ choice of 
		| ~Right() => 
			let 
				prval _ = itet out
				val _ = send (out, e)
			in 
				cut (out, inp)
			end
		| ~Left() => 
			let 
				val y = recv out 
				prval _ = recurse2 inp
				val _ = choose (inp, Left())
				val _ = send (inp, y)
			in 
				server (out, inp)
			end
	end
in 
	create (llam out => server (out, queue))
end



vtypedef queue (a:t@ype, n:int, r:int) = '(int n, chan(r, queue(a,n)))
//stadef queue (a:t@ype) = pquan(0,lam n=>queue(a,n))

//stadef enq (a:t@ype, n:int, p:stype) = pmsg(C,chan(C,queue(a,n))) :: pmsg(C,a) :: pmsg(S,chan(C,queue(a,n+1))) :: p
//stadef deq (a:t@ype, n:int, p:stype) = pmsg(C,chan(C,queue(a,n))) :: pite(n>0, pmsg(S,a) :: pmsg(S,chan(C,queue(a,n-1))) :: p, pend(S))
//stadef queue (a:t@ype) = pquan(C, lam n => pbrch(C, pfix(lam p => enq(a,n,p)), pfix(lam p => deq(a,n,p))))

extern fun nil {a:t@ype} (): queue(a,0,C)
extern fun enq {a:t@ype} {n:nat} (queue(a,n,C), a): queue(a,n+1,C)
extern fun deq {a:t@ype} {n:nat} (queue(a,n+1,C)): '(a, queue(a,n,C))
extern fun free {a:t@ype} (queue(a,0,C)): void
extern fun len {a:t@ype} {n:nat} (!queue(a,n,C)): int n

implement nil {a} () = '(0, empty {a} ())

implement enq {a} {n} (queue, x) = let 
	val '(n, ch) = queue
	prval _ = recurse2 ch 
	val _ = choose (ch, Left ())
	val _ = send (ch, x)
in 
	'(n+1,ch)
end

implement deq {a} {n} (queue) = let 
	val '(n, ch) = queue 
	prval _ = recurse2 ch 
	val _ = choose (ch, Right())
	prval _ = itet ch
	val x = recv ch 
in 
	'(x, '(n-1,ch))
end

implement free {a} (queue) = let 
	val '(n, ch) = queue 
	prval _ = recurse2 ch 
	val _ = choose (ch, Right ())
	prval _ = itef ch 
in 
	wait ch
end

implement len {a} {n} (queue) = queue.0

extern fun printall {n:nat} (queue (int, n, C)): void
implement printall {n} (queue) = 
	if len {int} queue = 0
	then (println! "nil"; free {int} queue)
	else 
		let 
			val '(x, queue) = deq {int} {n-1} queue 
			val _ = println! x
		in 
			printall queue 
		end

extern fun test (): void
implement test () = () where {

	val queue = nil {int} ()

	val queue = enq {int} (queue, 1)
	val queue = enq {int} (queue, 2)
	val queue = enq {int} (queue, 3)
	val queue = enq {int} (queue, 4)
	val queue = enq {int} (queue, 5)
	val queue = enq {int} (queue, 6)
	val queue = enq {int} (queue, 7)
	val queue = enq {int} (queue, 8)
	val queue = enq {int} (queue, 9)
	val queue = enq {int} (queue, 10)

	val _ = printall queue

}




