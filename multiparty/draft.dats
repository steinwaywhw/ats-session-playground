#include "draft.sats"



implement project {x} {s} (global, ep) = 
	case+ global.r of 
	| rtcls () => rtcls ()
	| rtmsg (epx, epy) => if epx = ep orelse epy = ep then rtmsg (epx, epy) else rtskip ()
	| rtseqs (a, b) => let 
		fun decompose {a,b:type} (prsession (a :: b)): '{prsession a, prsession b} = let 
			

		val '{fst, snd} = decompose
		proja = project (a, ep)