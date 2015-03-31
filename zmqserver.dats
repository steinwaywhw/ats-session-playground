#include "share/atspre_staload.hats"
//staload "/home/ubuntu/contrib/contrib/zeromq/SATS/zmq.sats"
staload "zmq.sats"

implement main0 () = () where {
  var major: int
  and minor: int
  and patch: int
  
  fun loop {l:addr | l>null} (socket: !zmq_socket_t l): void = () where {
      var msg : zmq_msg_t

      val () = zmq_msg_init (msg)
      val _ = zmq_msg_recv (msg, socket, 0)
      val () = println! ("errno = ", zmq_errno ())
      val _ = $extfcall (void, "printf", "%s", zmq_msg_data (msg))
      val () = zmq_msg_close (msg)

      val () = zmq_msg_init_size (msg, g1i2u 5)
      val () = $extfcall (void, "memcpy", zmq_msg_data (msg), "world\0", 6)
      val _ = zmq_msg_send (msg, socket, 0)
      val () = println! ("errno = ", zmq_errno ())
      val () = zmq_msg_close (msg)

  }
  
  val () = zmq_version(major, minor, patch)
  val () = println! ("Installed ZeroMQ version: ", major, ".", minor, ".", patch)

  val ctx = zmq_ctx_new ()
  val stream = zmq_socket (ctx, ZMQ_REP)
  val () = println! ("errno = ", zmq_errno ())


  val rc = zmq_bind (stream, "tcp://*:9999")
  val () = println! ("errno bind = ", zmq_errno ())
  val _ = assertloc (rc = 0)

  val () = loop (stream)
  

  val () = zmq_close (stream)
  val () = zmq_ctx_term (ctx)
}