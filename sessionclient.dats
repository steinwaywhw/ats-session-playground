#include "share/atspre_staload.hats"

staload "session.sats"
staload _ = "session.dats"
dynload "session.dats"




implement main0 () = () where {
	fun fserv (session: session (snd (string, rcv (string, nil)))): void = () where {
		val () = send (session, "hello")
		val rep = receive (session)
		val () = println! rep

		val () = close (session)
	}

	val _ = create_client (lam x => fserv x, "tcp://localhost:5555")
}

