PATSCC=patscc -ccats --tlcalopt-disable -IIATS ${PATSHOMERELOC} 
PATSCCTC=patscc -tcats -IIATS ${PATSHOMERELOC}
ERLC=erlc +debug_info
ELIXIRC=ERL_COMPILER_OPTIONS=debug_info elixirc 

# session.erl: session.&>
	# $(PATSCC) session.dats 
	# atscc2erl -i session_dats.c > session.erl 
	# erlc session.erl 
	# 

lib: session.ex draft.dats
	rm -f Elixir.Endpoint.beam
	rm -f Elixir.Session.beam
	rm -f Elixir.Message.beam
	rm -f Elixir.SessionData.beam
	rm -f Elixir.EndpointData.beam
	$(ELIXIRC) session.ex
	# $(PATSCC) draft.dats 
	# atscc2erl -i draft_dats.c > draft.erl 
	# $(ERLC) session.erl 
	# rm session.erl 

test: lib test.dats 
	$(PATSCC) test.dats
	atscc2erl -i test_dats.c > test.erl 
	$(ERLC) test.erl 
	rm test.erl

# server: lib server.dats
# 	$(PATSCC) server.dats
# 	atscc2erl -i server_dats.c > server.erl 
# 	$(ERLC) server.erl 
# 	rm server.erl

# test_link: lib test_link_client.dats test_link_server.dats test_link_middle.dats 
# 	$(PATSCC) test_link_client.dats test_link_server.dats test_link_middle.dats 
# 	atscc2erl -i test_link_client_dats.c > test_link_client.erl 
# 	atscc2erl -i test_link_server_dats.c > test_link_server.erl 
# 	atscc2erl -i test_link_middle_dats.c > test_link_middle.erl 
# 	$(ERLC) test_link_client.erl test_link_server.erl test_link_middle.erl 
# 	rm test_link_client.erl test_link_server.erl test_link_middle.erl 

clean:
	rm -f *.beam 
	rm -f *ats.c 
	rm -f *.dat 
	rm test.erl 