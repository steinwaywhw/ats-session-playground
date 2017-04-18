staload "session.sats"
staload UN = "prelude/SATS/unsafe.sats"

implement parr {r,r0} {p,q} (chan) = let 
	val chan = $UN.castvwtp0 {chan(r,msg(1-r,chan(r,p))::msg(1-r,chan(r,q))::nil(r))} {chan(r,mult(r0,p,q))} chan
	val p = recv {r} {msg(1-r,chan(r,q))::nil(r)} {chan(r,p)} chan 
	val q = recv {r} {nil(r)} {chan(r,q)} chan 
	val _ = close chan 
in 
	@(p, q)
end


implement tensor {r,r0} {p,q} (chan, fp, fq) = let 
	val pclient = create {r,1-r} (fp)
	val qclient = create {r,1-r} (fq)
	val chan = $UN.castvwtp0 {chan(r,msg(r,chan(1-r,p))::msg(r,chan(1-r,q))::nil(1-r))} {chan(r,mult(r0,p,q))} chan
	val _ = send {r} {msg(r,chan(1-r,q))::nil(1-r)} {chan(1-r,p)} (chan, pclient)
	val _ = send {r} {nil(1-r)} {chan(1-r,q)}(chan, qclient)
	val _ = wait chan
in 
end
