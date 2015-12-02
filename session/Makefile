PATSCC=patscc -ccats --tlcalopt-disable -IIATS ${PATSHOMERELOC}
ERLC=erlc +debug_info
ELIXIRC=ERL_COMPILER_OPTIONS=debug_info elixirc 
# session.erl: session.dats
	# $(PATSCC) session.dats 
	# atscc2erl -i session_dats.c > session.erl 
	# erlc session.erl 
	# 

lib: session.ex
	rm -f Elixir.Channel.beam
	rm -f Elixir.Session.beam
	$(ELIXIRC) session.ex

client: lib client.dats
	$(PATSCC) client.dats
	atscc2erl -i client_dats.c > client.erl 
	$(ERLC) client.erl 

server: lib server.dats
	$(PATSCC) server.dats
	atscc2erl -i server_dats.c > server.erl 
	$(ERLC) server.erl 

clean:
	rm -f *.beam 
	rm -f *ats.c 
	rm -f *.dat 
	rm server.erl client.erl