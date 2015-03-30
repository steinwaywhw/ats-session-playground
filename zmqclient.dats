#include "share/atspre_staload.hats"
staload "/home/ubuntu/contrib/contrib/zeromq/SATS/zmq.sats"


implement main0 () = () where {
  var major: int
  and minor: int
  and patch: int
  
  fun loop (socket: !zmqsock1): void = () where {
      var msg : zmqmsg_t
      
      val () = zmq_msg_init_size_exn (msg, g1i2u 5)
      val () = $extfcall (void, "memcpy", zmq_msg_data (msg), "hello", 5)
      val _ = zmq_msg_send (msg, socket, 0)
      val () = zmq_msg_close_exn (msg)
      
      val () = zmq_msg_init_exn (msg)
      val _ = zmq_msg_recv_exn (msg, socket, 0)
      val _ = $extfcall (void, "printf", "%s", zmq_msg_data (msg))
      val () = zmq_msg_close_exn (msg)
  }
  
  val () = zmq_version(major, minor, patch)
  val () = println! ("Installed ZeroMQ version: ", major, ".", minor, ".", patch)
  
  val ctx = zmq_ctx_new_exn ()
  val stream = zmq_socket_exn (ctx, ZMQ_STREAM)
  val () = zmq_connect_exn (stream, "tcp//localhost:8888")
  val () = loop (stream)
  
  val () = zmq_close_exn (stream)
  val () = zmq_ctx_destroy_exn (ctx)
}