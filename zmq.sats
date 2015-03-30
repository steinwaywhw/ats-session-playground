


absvtype zmq_ctx_t (l:addr) = ptr 
absvtype zmq_socket_t (l:addr) = ptr 

(*
ZMQ_EXPORT void *zmq_ctx_new (void);
ZMQ_EXPORT int zmq_ctx_term (void *context);
ZMQ_EXPORT int zmq_ctx_shutdown (void *ctx_);
ZMQ_EXPORT int zmq_ctx_set (void *context, int option, int optval);
ZMQ_EXPORT int zmq_ctx_get (void *context, int option);
*)


fun zmq_ctx_new (): [l:addr | l>null] zmq_ctx_t l 
fun zmq_ctx_term {l:addr | l>null} (zmq_ctx_t l): void 
fun zmq_ctx_shutdown {l:addr | l>null} (zmq_ctx_t l): void 
fun zmq_ctx_set {l:addr | l>null} (!zmq_ctx_t l, int, int): void
fun zmq_ctx_get {l:addr | l>null} (!zmq_ctx_t l, int): int 


(*
ZMQ_EXPORT int zmq_errno (void);
*  Resolves system errors and 0MQ errors to human-readable string.           
ZMQ_EXPORT const char *zmq_strerror (int errnum);

 Run-time API version detection                                            
ZMQ_EXPORT void zmq_version (int *major, int *minor, int *patch);
*)



(*typedef union zmq_msg_t {unsigned char _ [64]; void *p; } zmq_msg_t;*)
absvt@ype zmq_msg_t = $extype "zmq_msg_t"

(*typedef void (zmq_free_fn) (void *data, void *hint);*)
typedef zmq_free_fn = (ptr, ptr) -> void 

(*
ZMQ_EXPORT int zmq_msg_init (zmq_msg_t *msg);
ZMQ_EXPORT int zmq_msg_init_size (zmq_msg_t *msg, size_t size);
ZMQ_EXPORT int zmq_msg_init_data (zmq_msg_t *msg, void *data,
    size_t size, zmq_free_fn *ffn, void *hint);
ZMQ_EXPORT int zmq_msg_send (zmq_msg_t *msg, void *s, int flags);
ZMQ_EXPORT int zmq_msg_recv (zmq_msg_t *msg, void *s, int flags);
ZMQ_EXPORT int zmq_msg_close (zmq_msg_t *msg);
ZMQ_EXPORT int zmq_msg_move (zmq_msg_t *dest, zmq_msg_t *src);
ZMQ_EXPORT int zmq_msg_copy (zmq_msg_t *dest, zmq_msg_t *src);
ZMQ_EXPORT void *zmq_msg_data (zmq_msg_t *msg);
ZMQ_EXPORT size_t zmq_msg_size (zmq_msg_t *msg);
ZMQ_EXPORT int zmq_msg_more (zmq_msg_t *msg);
ZMQ_EXPORT int zmq_msg_get (zmq_msg_t *msg, int property);
ZMQ_EXPORT int zmq_msg_set (zmq_msg_t *msg, int property, int optval);
ZMQ_EXPORT const char *zmq_msg_gets (zmq_msg_t *msg, const char *property);
ZMQ_EXPORT int zmq_msg_set_routing_id(zmq_msg_t *msg, uint32_t routing_id);
ZMQ_EXPORT uint32_t zmq_msg_get_routing_id(zmq_msg_t *msg);
*)

(*fun zmq_msg_init (&zmq_msg_t? >> _): void *)
(*fun zmq_msg_init_size (&zmq_msg_t? >> _, size_t): void*)
(*fun zmq_msg_init_data (&zmq_msg_t? >> _, ptr, size_t, zma_free_fn, ptr): void *)
(*fun zmq_msg_send (&zmq_msg_t? >> _, !zmq_socket_t, int): size_t*)
(*fun zmq_msg_*)

(*
ZMQ_EXPORT void *zmq_socket (void *, int type);
ZMQ_EXPORT int zmq_close (void *s);
ZMQ_EXPORT int zmq_setsockopt (void *s, int option, const void *optval,
    size_t optvallen);
ZMQ_EXPORT int zmq_getsockopt (void *s, int option, void *optval,
    size_t *optvallen);
ZMQ_EXPORT int zmq_bind (void *s, const char *addr);
ZMQ_EXPORT int zmq_connect (void *s, const char *addr);
ZMQ_EXPORT int zmq_unbind (void *s, const char *addr);
ZMQ_EXPORT int zmq_disconnect (void *s, const char *addr);
ZMQ_EXPORT int zmq_send (void *s, const void *buf, size_t len, int flags);
ZMQ_EXPORT int zmq_send_const (void *s, const void *buf, size_t len, int flags);
ZMQ_EXPORT int zmq_recv (void *s, void *buf, size_t len, int flags);
ZMQ_EXPORT int zmq_socket_monitor (void *s, const char *addr, int events);
*)

fun zmq_socket {l:addr | l>null} (!zmq_ctx_t l, int): {m:addr | m>null} zmq_socket_t m
fun zmq_close {l:addr | l>null} (zmq_socket_t l): void 
fun zmq_setsockopt {l:addr | l>null} (!zmq_socket_t l, option: int, value: ptr, len: size_t): void
fun zmq_getsockopt {l:addr | l>null} (!zmq_socket_t l, option: int, value: ptr, len: &size_t >> _): void 
fun zmq_bind {l:addr | l>null} (!zmq_socket_t l, address: string): void 
fun zmq_unbind {l:addr | l>null} (!zmq_socket_t l, address: string): void 
fun zmq_connect {l:addr | l>null} (!zmq_socket_t l, address: string): void 
fun zmq_disconnect {l:addr | l>null} (!zmq_socket_t l, address: string): void 


// Context options  
macdef ZMQ_IO_THREADS  = $extval(int, "ZMQ_IO_THREADS")
macdef ZMQ_MAX_SOCKETS = $extval(int, "ZMQ_MAX_SOCKETS")

// Default for new contexts                                                  
macdef ZMQ_IO_THREADS_DFLT  = $extval(int, "ZMQ_IO_THREADS_DFLT")
macdef ZMQ_MAX_SOCKETS_DFLT = $extval(int, "ZMQ_MAX_SOCKETS_DFLT")

// socket types

macdef ZMQ_PAIR    = $extval(int, "ZMQ_PAIR")
macdef ZMQ_PUB     = $extval(int, "ZMQ_PUB")
macdef ZMQ_SUB     = $extval(int, "ZMQ_SUB")
macdef ZMQ_REQ     = $extval(int, "ZMQ_REQ")
macdef ZMQ_REP     = $extval(int, "ZMQ_REP")
macdef ZMQ_DEALER  = $extval(int, "ZMQ_DEALER")
macdef ZMQ_ROUTER  = $extval(int, "ZMQ_ROUTER")
macdef ZMQ_PULL    = $extval(int, "ZMQ_PULL")
macdef ZMQ_PUSH    = $extval(int, "ZMQ_PUSH")
macdef ZMQ_XPUB    = $extval(int, "ZMQ_XPUB")
macdef ZMQ_XSUB    = $extval(int, "ZMQ_XSUB")
macdef ZMQ_STREAM  = $extval(int, "ZMQ_STREAM")

// socket options

macdef ZMQ_AFFINITY            = $extval(int, "ZMQ_AFFINITY")
macdef ZMQ_IDENTITY            = $extval(int, "ZMQ_IDENTITY")
macdef ZMQ_SUBSCRIBE           = $extval(int, "ZMQ_SUBSCRIBE")
macdef ZMQ_UNSUBSCRIBE         = $extval(int, "ZMQ_UNSUBSCRIBE")
macdef ZMQ_RATE                = $extval(int, "ZMQ_RATE")
macdef ZMQ_RECOVERY_IVL        = $extval(int, "ZMQ_RECOVERY_IVL")
macdef ZMQ_SNDBUF              = $extval(int, "ZMQ_SNDBUF")
macdef ZMQ_RCVBUF              = $extval(int, "ZMQ_RCVBUF")
macdef ZMQ_RCVMORE             = $extval(int, "ZMQ_RCVMORE")
macdef ZMQ_FD                  = $extval(int, "ZMQ_FD")
macdef ZMQ_EVENTS              = $extval(int, "ZMQ_EVENTS")
macdef ZMQ_TYPE                = $extval(int, "ZMQ_TYPE")
macdef ZMQ_LINGER              = $extval(int, "ZMQ_LINGER")
macdef ZMQ_RECONNECT_IVL       = $extval(int, "ZMQ_RECONNECT_IVL")
macdef ZMQ_BACKLOG             = $extval(int, "ZMQ_BACKLOG")
macdef ZMQ_RECONNECT_IVL_MAX   = $extval(int, "ZMQ_RECONNECT_IVL_MAX")
macdef ZMQ_MAXMSGSIZE          = $extval(int, "ZMQ_MAXMSGSIZE")
macdef ZMQ_SNDHWM              = $extval(int, "ZMQ_SNDHWM")
macdef ZMQ_RCVHWM              = $extval(int, "ZMQ_RCVHWM")
macdef ZMQ_MULTICAST_HOPS      = $extval(int, "ZMQ_MULTICAST_HOPS")
macdef ZMQ_RCVTIMEO            = $extval(int, "ZMQ_RCVTIMEO")
macdef ZMQ_SNDTIMEO            = $extval(int, "ZMQ_SNDTIMEO")
macdef ZMQ_LAST_ENDPOINT       = $extval(int, "ZMQ_LAST_ENDPOINT")
macdef ZMQ_ROUTER_MANDATORY    = $extval(int, "ZMQ_ROUTER_MANDATORY")
macdef ZMQ_TCP_KEEPALIVE       = $extval(int, "ZMQ_TCP_KEEPALIVE")
macdef ZMQ_TCP_KEEPALIVE_CNT   = $extval(int, "ZMQ_TCP_KEEPALIVE_CNT")
macdef ZMQ_TCP_KEEPALIVE_IDLE  = $extval(int, "ZMQ_TCP_KEEPALIVE_IDLE")
macdef ZMQ_TCP_KEEPALIVE_INTVL = $extval(int, "ZMQ_TCP_KEEPALIVE_INTVL")
macdef ZMQ_TCP_ACCEPT_FILTER   = $extval(int, "ZMQ_TCP_ACCEPT_FILTER")
macdef ZMQ_IMMEDIATE           = $extval(int, "ZMQ_IMMEDIATE")
macdef ZMQ_XPUB_VERBOSE        = $extval(int, "ZMQ_XPUB_VERBOSE")
macdef ZMQ_ROUTER_RAW          = $extval(int, "ZMQ_ROUTER_RAW")
macdef ZMQ_IPV6                = $extval(int, "ZMQ_IPV6")
macdef ZMQ_MECHANISM           = $extval(int, "ZMQ_MECHANISM")
macdef ZMQ_PLAIN_SERVER        = $extval(int, "ZMQ_PLAIN_SERVER")
macdef ZMQ_PLAIN_USERNAME      = $extval(int, "ZMQ_PLAIN_USERNAME")
macdef ZMQ_PLAIN_PASSWORD      = $extval(int, "ZMQ_PLAIN_PASSWORD")
macdef ZMQ_CURVE_SERVER        = $extval(int, "ZMQ_CURVE_SERVER")
macdef ZMQ_CURVE_PUBLICKEY     = $extval(int, "ZMQ_CURVE_PUBLICKEY")
macdef ZMQ_CURVE_SECRETKEY     = $extval(int, "ZMQ_CURVE_SECRETKEY")
macdef ZMQ_CURVE_SERVERKEY     = $extval(int, "ZMQ_CURVE_SERVERKEY")
macdef ZMQ_PROBE_ROUTER        = $extval(int, "ZMQ_PROBE_ROUTER")
macdef ZMQ_REQ_CORRELATE       = $extval(int, "ZMQ_REQ_CORRELATE")
macdef ZMQ_REQ_RELAXED         = $extval(int, "ZMQ_REQ_RELAXED")
macdef ZMQ_CONFLATE            = $extval(int, "ZMQ_CONFLATE")
macdef ZMQ_ZAP_DOMAIN          = $extval(int, "ZMQ_ZAP_DOMAIN")

//  Message options                                                           
macdef ZMQ_MORE = $extval(int, "ZMQ_MORE")

//  Send/recv options.                                                        
macdef ZMQ_DONTWAIT = $extval(int, "ZMQ_DONTWAIT")
macdef ZMQ_SNDMORE  = $extval(int, "ZMQ_SNDMORE")

//  Security mechanisms                                                       
macdef ZMQ_NULL  = $extval(int, "ZMQ_NULL")
macdef ZMQ_PLAIN = $extval(int, "ZMQ_PLAIN")
macdef ZMQ_CURVE = $extval(int, "ZMQ_CURVE")

// socket transport events (tcp and ipc only)
macdef ZMQ_EVENT_CONNECTED       = $extval(int, "ZMQ_EVENT_CONNECTED")
macdef ZMQ_EVENT_CONNECT_DELAYED = $extval(int, "ZMQ_EVENT_CONNECT_DELAYED")
macdef ZMQ_EVENT_CONNECT_RETRIED = $extval(int, "ZMQ_EVENT_CONNECT_RETRIED")

macdef ZMQ_EVENT_LISTENING       = $extval(int, "ZMQ_EVENT_LISTENING")
macdef ZMQ_EVENT_BIND_FAILED     = $extval(int, "ZMQ_EVENT_BIND_FAILED")

macdef ZMQ_EVENT_ACCEPTED        = $extval(int, "ZMQ_EVENT_ACCEPTED")
macdef ZMQ_EVENT_ACCEPT_FAILED   = $extval(int, "ZMQ_EVENT_ACCEPT_FAILED")

macdef ZMQ_EVENT_CLOSED          = $extval(int, "ZMQ_EVENT_CLOSED")
macdef ZMQ_EVENT_CLOSE_FAILED    = $extval(int, "ZMQ_EVENT_CLOSE_FAILED")
macdef ZMQ_EVENT_DISCONNECTED    = $extval(int, "ZMQ_EVENT_DISCONNECTED")
macdef ZMQ_EVENT_MONITOR_STOPPED = $extval(int, "ZMQ_EVENT_MONITOR_STOPPED")
macdef ZMQ_EVENT_ALL             = $extval(int, "ZMQ_EVENT_ALL")

// I/O multiplexing
macdef ZMQ_POLLIN  = $extval(int, "ZMQ_POLLIN")
macdef ZMQ_POLLOUT = $extval(int, "ZMQ_POLLOUT")
macdef ZMQ_POLLERR = $extval(int, "ZMQ_POLLERR")

// error numbers 
macdef ENOTSUP         = $extval(int, "ENOTSUP") 
macdef EPROTONOSUPPORT = $extval(int, "EPROTONOSUPPORT") 
macdef ENOBUFS         = $extval(int, "ENOBUFS") 
macdef ENETDOWN        = $extval(int, "ENETDOWN") 
macdef EADDRINUSE      = $extval(int, "EADDRINUSE") 
macdef EADDRNOTAVAIL   = $extval(int, "EADDRNOTAVAIL") 
macdef ECONNREFUSED    = $extval(int, "ECONNREFUSED") 
macdef EINPROGRESS     = $extval(int, "EINPROGRESS") 
macdef ENOTSOCK        = $extval(int, "ENOTSOCK") 
macdef EMSGSIZE        = $extval(int, "EMSGSIZE") 
macdef EAFNOSUPPORT    = $extval(int, "EAFNOSUPPORT") 
macdef ENETUNREACH     = $extval(int, "ENETUNREACH") 
macdef ECONNABORTED    = $extval(int, "ECONNABORTED") 
macdef ECONNRESET      = $extval(int, "ECONNRESET") 
macdef ENOTCONN        = $extval(int, "ENOTCONN") 
macdef ETIMEDOUT       = $extval(int, "ETIMEDOUT") 
macdef EHOSTUNREACH    = $extval(int, "EHOSTUNREACH") 
macdef ENETRESET       = $extval(int, "ENETRESET")
macdef EFSM            = $extval(int, "EFSM")
macdef ENOCOMPATPROTO  = $extval(int, "ENOCOMPATPROTO")
macdef ETERM           = $extval(int, "ETERM")
macdef EMTHREAD        = $extval(int, "EMTHREAD")
