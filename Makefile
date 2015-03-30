

server: server.sats server.dats
	patscc -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -o server server.dats -lpthread
	
client: client.sats client.dats
	patscc -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -o client client.dats -lpthread -I/home/ubuntu/contrib/contrib -L/usr/local/lib -lzmq

clean:
	rm -f *.c server client
	
zmq: zmqclient.dats zmqserver.dats
	patscc -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -o client zmqclient.dats -lpthread -I/home/ubuntu/contrib/contrib -L/usr/local/lib -lzmq
	patscc -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -o server zmqserver.dats -lpthread -I/home/ubuntu/contrib/contrib -L/usr/local/lib -lzmq
