staload "./session.sats"
staload UN = "prelude/SATS/unsafe.sats"

#define ATS_EXTERN_PREFIX "libsession__"

#define ATS_DYNLOADFLAG 0

implement create {r1,r2} {p} (f) = let 

	val '(pos, neg) = $extfcall('(chan(r2,p), chan(r1,p)), "libsession__create")

	extern fun spawn_link (() -<lincloptr1> void): void = "mac#%"

	val _ = spawn_link (llam () =<cloptr1> let 
							val _ = f(pos)
							prval _ = $UN.cast2void(f)
						in 
						end)
	
in 
	neg
end


//implement request {r,r0} {p} (ch) = let 
//	val '(pos, neg) = $extfcall('(chan(r,p), chan(1-r,p)), "libsession__create")

//	extern castfn interp (!chan(r,prep(r0,p))>>chan(r,pmsg(r,chan(1-r,p))::prep(r0,p))): void
//	val _ = interp ch 
//	val _ = send (ch, neg)
//in 
//	pos
//end


//implement accept {r,r0} {p:stype} (ch, f) = let 
//	extern castfn interp (!chan(r,prep(r0,p))>>chan(r,pmsg(1-r,chan(r,p))::prep(r0,p))): void
//	val _ = interp ch 
//	val pos = recv ch 

//	extern fun spawn_link (() -<lincloptr1> void): void = "mac#%"
//in 
//	spawn_link (llam () =<cloptr1> f pos)
//end