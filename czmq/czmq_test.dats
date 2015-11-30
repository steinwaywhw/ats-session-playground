




(*

client:
	sock = zsock_new ZSOCK_DEALER
	check
	rand = $extfcall (int, "rand ()")
	id = $extfcall (zstr_t, "zsys_sprintf", "%04X", rand)
	
	zsock_set_identity (sock, zstr_to_string id)
	zsock_connect (sock, ....)

	
	zmsg_send ...

*)