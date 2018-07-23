staload "./set.sats"
staload "./session.sats"

staload UN="prelude/SATS/unsafe.sats"

#define P msg(0,2,int) :: msg(1,int) :: nil(1)

extern fun server {self:roles} (chan(self,P)): void





implement main0 () = let

	val roles = emp() + 0

	extern fun get_input (): [n:nat] int n = "mac#%"

	val stype = Nil (get_input ())
	val stype = Msg (1, stype)
	val stype = Msg (0, 2, stype)

	val chan = create {0+emp} {P} (roles, stype, llam (chan) => server chan)

	val _ = send_one (chan, 10)
	val answer = receive_all (chan)
	val stype = get_type (chan)
in 
	case+ stype of 
	| Nil (r) => 
		if mem(roles, r)
		then close chan 
		else wait chan
	| _ =/=>> $UN.cast2void chan
end

implement cut_residual {rs1,rs2} {s} (ch1, ch2) = let 
	val stype = get_type ch1 
	val rs3 = ~(get)

	fun server (ch3: chan(~(rs1*rs2),s)): void = 
		case+ stype of 
		| Nil r => 
			if mem()

in 
end