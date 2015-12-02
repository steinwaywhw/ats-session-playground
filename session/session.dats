staload "session.sats"
staload UN = "prelude/SATS/unsafe.sats"


//extern praxi dual {p1,p2:type} (): DUAL (p1, p2)

implement dualof {p1,p2} (pf | ch) = let 
	prval () = $UN.castview2void ch 
in 
end 

//extern fun testchannel {p:type} (): channel p = "mac#"
//%{
//int testchannel () {
//	return (void*)0;
//}
//%}








extern fun client (): void 
implement client () = let 

	extern praxi dual (): DUAL (snd string :: rcv string :: cls (), rcv string :: snd string :: cls ())
	
	prval pf1 = dual_base1 ()          (* cls <> cls *)
	prval pf2 = dual_base2 {string} () (* snd string <> rcv string *)
	prval pf3 = dual_comm pf2          (* rcv string <> snd string *)
	prval pf = dual_ind2 (pf2, pf1)    (* snd :: cls <> rcv :: cls *)
	prval pf = dual_ind2 (pf3, pf)     (* rcv :: snd :: cls <> snd :: rcv :: cls *)
	prval pf = dual_comm pf       

	fun loop (ch: channel (rcv string :: snd string :: cls ())): void = let 
		val msg = receive (ch)
		val _ = println! msg
		val _ = send (ch, "world")
	in 
		close ch 
	end 

	val name = make_name {snd string :: rcv string :: cls()} ("shared")

//	prval pf = dual ()
	val ch = request (pf | name)
in 
	loop ch 
end 

extern fun main0_erl (): void = "mac#"
implement main0_erl () = () where {
	val _ = client ()
	val _ = server ()
}


////
extern fun dualof {a:vt@ype} {p:protocol} (channel p): [p0:protocol] channel p0

implement dualof {a} {p} (ch) = 
	case+ ch of 
	| nil _ => nil{nil} ()
	| snd ch => rcv (dualof ch)
	| rcv ch => snd (dualof ch)
	| dual ch => ch 


////
implement normalize {p1} (ch) = let 

	fun case1 {a:vt@ype} {p:protocol}
			(ch: !channel (dual (snd (a, p))) >> channel (rcv (a, dual p))): 
			(EQ (dual (snd (a, p)), rcv (a, dual p)) | void) = let 

		prval pf = EQ_REFLC{p} ()
		prval pf = EQ_IND_1 pf 
		prval () = $UN.castview2void ch

	in 
		(pf | ())
	end

	fun case2 {a:vt@ype} {p:protocol}
			(ch: !channel (dual (rcv (a, p))) >> channel (snd (a, dual p))): 
			(EQ (dual (rcv (a, p)), snd (a, dual p)) | void) = let 

		prval pf = EQ_REFLC{p} ()
		prval pf = EQ_IND_2 pf 
		prval () = $UN.castview2void ch
	in 
		(pf | ())
	end

	fun case3 {a:vt@ype} {p:protocol}
			(ch: !channel (dual nil) >> channel (nil)): 
			(EQ (dual nil, nil) | void) = let 

		prval pf = EQ_IND_0 ()
		prval () = $UN.castview2void ch
	in 
		(pf | ())
	end

	fun case4 {a:vt@ype} {p:protocol}
			(ch: !channel (dual (dual p)) >> channel p): 
			(EQ (dual (dual p), p) | void) = let 

		prval pf = EQ_REFLC{p} ()
		prval pf = EQ_DUAL (pf)
		prval () = $UN.castview2void ch
	in 
		(pf | ())
	end

	fun case5 {a:vt@ype} {p:protocol}
			(ch: !channel (snd (a, p))): 
			(EQ (snd (a, p), snd (a, p)) | void) = let 

		prval pf = EQ_REFLC{snd (a, p)} ()
		prval () = $UN.castview2void ch
	in 
		(pf | ())
	end

	fun case6 {a:vt@ype} {p:protocol}
			(ch: !channel (rcv (a, p))): 
			(EQ (rcv (a, p), rcv (a, p)) | void) = let 

		prval pf = EQ_REFLC{rcv (a, p)} ()
		prval () = $UN.castview2void ch
	in 
		(pf | ())
	end

	fun case7 {a:vt@ype} {p:protocol}
			(ch: !channel nil): 
			(EQ (nil, nil) | void) = let 

		prval pf = EQ_REFLC{nil} ()
		prval () = $UN.castview2void ch
	in 
		(pf | ())
	end

	symintr aux 
	overload aux with case1
	overload aux with case2
	overload aux with case3
	overload aux with case4
	overload aux with case5
	overload aux with case6
	overload aux with case7

in 
	aux ch 
end

////




extern fun server (): void
extern fun client (): void 

implement server () = let 
	val name = make_name{snd (int, nil)} ("serveraddr")
	fun loop {p:protocol} (ch: channel p): void = () where {
		val () = send (chan, 1)
		val () = wait (chan)
	}
in 
	accept (name, llam ch => loop ch)	
end	


implement client () = () where {
	val name = make_name{snd (int, nil)} ("serveraddr") 
	val chan = request (name)
	val x = recv_2 (chan)
	val () = close (chan)

}

implement main0 () = () where {
	val _ = server ()
	val _ = client ()
}