

# server: server.sats server.dats
# 	patscc -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -o server server.dats -lpthread
	
# client: client.sats client.dats
# 	patscc -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -o client client.dats -lpthread -I/home/ubuntu/contrib/contrib -L/usr/local/lib -lzmq

zmq: zmqclient.dats zmqserver.dats
	patscc -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -o client zmqclient.dats -lpthread -L/usr/local/lib -lzmq -lczmq -I/Users/hwwu/Git/ats-czmq
	patscc -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -o server zmqserver.dats -lpthread -L/usr/local/lib -lzmq -lczmq -I/Users/hwwu/Git/ats-czmq

clean:
	rm -f *.c server client

zmqtest: zmq 
	./server & ./client

session: session.dats sessionclient.dats  sessionserver.dats 
	patscc -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -o client sessionclient.dats session.sats session.dats -L/usr/local/lib -lzmq
	patscc -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -o server sessionserver.dats session.sats session.dats -L/usr/local/lib -lzmq
