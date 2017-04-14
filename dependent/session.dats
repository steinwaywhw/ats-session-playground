staload "sessions.sats"
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


