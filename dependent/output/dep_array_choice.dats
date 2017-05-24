
staload "../session.sats"
staload UN = "prelude/SATS/unsafe.sats"

#define S 0 
#define C 1

stadef repeat (a:t@ype, n:int) = pfix2(lam (p:(int->stype)):int->stype => lam (n:int):stype => pite(n>0, pmsg(S,a)::p(n-1), pend(S)),n)
stadef array (a:t@ype) = pquan(S,lam (n:int):stype => pbrch(C, pmsg(S,int(n))::repeat(a,n), pend(C)))

extern fun server {a:t@ype} {n:nat} (chan(S,array(a)), arrayref(a,n), int(n)): void
extern fun client {a:t@ype} (chan(C,array(a))): [n:nat] '(int(n), arrayref(a,n))


implement server {a} {n} (ch, data, len) = let 
	prval _ = unify ch 
	val choice = offer ch

	fun loop {n,m:nat|n <= m} (ch: chan(S,repeat(a,n)), x:int(n), data:arrayref(a,m), len:int(m)): void = 
		if x = 0 then 
			let prval () = recurse2 ch
			    prval () = itef ch 
			 in close ch end 
		else
			let prval () = recurse2 ch
			    prval () = itet ch 
			      val () = send (ch, data[len-x])
			 in loop (ch, x-1, data, len) end
in 
	case+ choice of 
	| ~Left () => (send (ch,len); loop {n,n} (ch, len, data, len))
	| ~Right () => wait ch
end

implement client {a} (ch) = let 
	prval _ = exify ch
	val _ = choose (ch, Left ())
	val len = recv ch 
	val _ = assertloc (len >= 0)
	val data = arrayref_make_elt (i2sz len, $UN.cast{a} 0)

	fun loop {n,m:nat|n <= m} (ch: chan(C,repeat(a,n)), x:int(n), data:arrayref(a,m), len:int(m)): void = 
		if x = 0 then 
			let prval () = recurse2 ch
			    prval () = itef ch 
			 in wait ch end 
		else
			let prval () = recurse2 ch
			    prval () = itet ch 
			      val  _ =  data[len-x] := (recv ch)
			 in loop (ch, x-1, data, len) end
	val _ = loop (ch, len, data, len)
in 
	'(len, data)
end


