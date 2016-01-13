PATSCC=patscc -ccats --tlcalopt-disable -IIATS ${PATSHOMERELOC}
PATSCCTC=patscc -tcats -IIATS ${PATSHOMERELOC}
ERLC=erlc +debug_info
ELIXIRC=ERL_COMPILER_OPTIONS=debug_info elixirc 
# session.erl: session.dats
	# $(PATSCC) session.dats 
	# atscc2erl -i session_dats.c > session.erl 
	# erlc session.erl 
	# 

lib: session.ex session.dats
	rm -f Elixir.Channel.beam
	rm -f Elixir.Session.beam
	rm -f Elixir.Message.beam
	$(ELIXIRC) session.ex
	# $(PATSCC) session.dats 
	# atscc2erl -i session_dats.c > session.erl 
	# $(ERLC) session.erl 
	# rm session.erl 

client: lib client.dats 
	$(PATSCC) client.dats
	atscc2erl -i client_dats.c > client.erl 
	$(ERLC) client.erl 
	rm client.erl

server: lib server.dats
	$(PATSCC) server.dats
	atscc2erl -i server_dats.c > server.erl 
	$(ERLC) server.erl 
	rm server.erl

test_link: lib test_link_client.dats test_link_server.dats test_link_middle.dats 
	$(PATSCC) test_link_client.dats test_link_server.dats test_link_middle.dats 
	atscc2erl -i test_link_client_dats.c > test_link_client.erl 
	atscc2erl -i test_link_server_dats.c > test_link_server.erl 
	atscc2erl -i test_link_middle_dats.c > test_link_middle.erl 
	$(ERLC) test_link_client.erl test_link_server.erl test_link_middle.erl 
	rm test_link_client.erl test_link_server.erl test_link_middle.erl 

clean:
	rm -f *.beam 
	rm -f *ats.c 
	rm -f *.dat 
	rm server.erl client.erl