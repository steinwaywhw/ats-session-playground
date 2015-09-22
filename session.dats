#include "share/atspre_staload.hats"

staload "session.sats"
staload "zmq.sats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libc/SATS/string.sats"
staload _ = "libc/DATS/string.dats"

vtypedef session_ctx = [m:addr|m>null] [n:addr|n>null] '{ctx=zmq_ctx_t m, sock=zmq_socket_t n}
assume session (p) = session_ctx


implement close (session) = () where {
	val () = zmq_close (session.sock)
	val () = zmq_ctx_term (session.ctx)

	prval _ = $UN.cast2void(session)
}


implement create_server {p} (fserv, addr) = () where { 
	val ctx = zmq_ctx_new ()
	val sock = zmq_socket (ctx, ZMQ_REP)
	val session = '{ctx=ctx, sock=sock}
	val rc = zmq_bind (session.sock, addr)
	//val _ = assertloc{int} (rc = 0)

	val s = $UN.castvwtp0{session (p)}(session)
	val () = fserv (s)

}

implement create_client {p} (fserv, addr) = () where {
	val ctx = zmq_ctx_new ()
	val sock = zmq_socket (ctx, ZMQ_REQ)
	val session = '{ctx=ctx, sock=sock}	val rc = zmq_connect (session.sock, addr)
	//val _ = assertloc{int} (rc = 0)

	val s = $UN.castvwtp0{session (p)}(session)
	val () = fserv (s)

}

implement send_server {p} (session, data) = () where {

	var msg : zmq_msg_t 
	val x = $extfcall (size_t, "strlen", data)
	val x = x + (i2sz 1)
	val () = zmq_msg_init_size (msg, x)
//	val () = $extfcall (void, "memcpy", zmq_msg_data msg, data, strlen (data))
	val _ = strcpy_unsafe (zmq_msg_data msg, data)
	val _  = zmq_msg_send (msg, session.sock, 0)
	val () = zmq_msg_close msg 

}

implement receive_server {p} (session) = data where {

	var msg : zmq_msg_t 
	val () = zmq_msg_init (msg)
	val _  = zmq_msg_recv (msg, session.sock, 0)

//	var d : string0_copy ("_____")

	//val _ = $extfcall (void, "strncpy", d, zmq_msg_data msg, 5)
//	val data = $UN.cast{string}(zmq_msg_data msg)
	val data = string0_copy ("_____")
	val _ = strcpy_unsafe (strptr2ptr data, $UN.cast{string} (zmq_msg_data msg))
	val data = strptr2string (data)
	val () = zmq_msg_close msg 
}

//implement send_client {p} (session) = () where {
	
//}

