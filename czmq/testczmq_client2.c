#include "czmq.h"
#include "pthread.h"

static void * client_task (void * args) {
	zsock_t * sock = zsock_new (ZMQ_DEALER);
	char identity [10];
    sprintf (identity, "%04X-%04X", randof (0x10000), randof (0x10000));

    zsock_set_identity (sock, identity);
    zsock_connect (sock, "tcp://localhost:5566");

    zmsg_t * msg = zmsg_new ();
    zmsg_addstr (msg, "Hello2");

    zmsg_send (&msg, sock);

    msg = zmsg_recv (sock);
    zmsg_dump (msg);

    zsock_destroy (&sock);

    return NULL;
}


int main () {
	client_task (NULL);

}