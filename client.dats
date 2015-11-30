

#include "share/atspre_staload.hats"

staload "/home/ubuntu/contrib/contrib/zeromq/SATS/zmq.sats"


implement main0 () = () where {
  var major: int
  and minor: int
  and patch: int
  
  val () = zmq_version(major, minor, patch)
  val () = println! ("Installed ZeroMQ version: ", major, ".", minor, ".", patch)
}