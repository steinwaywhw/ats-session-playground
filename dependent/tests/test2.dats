
staload "../session.sats"
#define :: pseq


vtypedef chan (r:int) = chan (r, pfix (lam p => pbrch (1, pmsg (0, int) :: p, pend (1))))


extern fun test2_server (chan 0): void 
extern fun test2_client (chan 1): void

implement test2_server (chan) = let 
	val _ = recurse chan 
	val c = offer chan
in 
	case+ c of 
	| ~Right () => wait chan
	| ~Left () => let 
		val _ = send (chan, $extfcall (int, "random"))
		in 
			test2_server chan
		end
end



implement test2_client (chan) = let 
	val _ = recurse chan 
	val _ = choose (chan, Left ())
	val i = recv chan
in 
	test2_client chan 
end