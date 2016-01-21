




test: testczmq_client.c testczmq_server.c
	gcc -o client1 testczmq_client.c -lzmq -lczmq -L/usr/local/lib -g
	gcc -o client2 testczmq_client2.c -lzmq -lczmq -L/usr/local/lib -g
	gcc -o server testczmq_server.c -lzmq -lczmq -L/usr/local/lib -g