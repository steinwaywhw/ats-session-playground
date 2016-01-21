#include "share/atspre_staload.hats"

staload "session.sats"
staload _ = "session.dats"
dynload "session.dats"




implement main0 () = () where {
	fun fserv (session: session (rcv (string, snd (string, nil)))): void = () where {
		val rep = receive (session)
		val () = println! rep
		val () = send (session, "world")
		val () = close (session)
	}

	val _ = create_server (lam x => fserv x, "tcp://*:5555")
}

