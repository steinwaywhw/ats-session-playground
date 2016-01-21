#include "czmq.h"
#include "pthread.h"


static void * server_task (void * args) {
	zsock_t * sock = zsock_new (ZMQ_ROUTER);
	zsock_bind (sock, "tcp://*:5566");

	while (true) {
		zmsg_t * msg = zmsg_recv (sock);
		zmsg_dump (msg);
		zframe_t * id = zmsg_pop (msg);
		zmsg_destroy (&msg);

		msg = zmsg_new ();
		zmsg_prepend (msg, &id);
		zmsg_addstr (msg, "World");
		zmsg_send (&msg, sock);
	}	

	return NULL;
}

int main () {
	server_task (NULL);

}