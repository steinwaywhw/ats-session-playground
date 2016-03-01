
PATSOPT=patsopt -IATS ${PATSHOMERELOC} -IATS ~/Git/ats-utils
PATSOLVE=patsolve_z3 
PATSCC=patscc -ccats --tlcalopt-disable -IIATS ${PATSHOMERELOC} -IIATS ~/Git/ats-utils
PATSCCTC=patscc -tcats -IIATS ${PATSHOMERELOC} -IIATS ~/Git/ats-utils
ATS2ERL=atscc2erl
ERLC=erlc +debug_info
ELIXIRC=ERL_COMPILER_OPTIONS=debug_info elixirc 


# session.erl: session.&>
	# $(PATSCC) session.dats 
	# atscc2erl -i session_dats.c > session.erl 
	# erlc session.erl 
	# 

lib: session.ex
	$(ELIXIRC) session.ex



test: lib test.dats 
	$(PATSOPT) -tc --constraint-export -d test.dats | $(PATSOLVE) -i
	$(PATSCC) test.dats
	# $(ATS2ERL) -i test_dats.c > test.erl 
	# $(ERLC) test.erl 
	# rm test.erl

tc: session.sats session.dats
	$(PATSOPT) -tc --constraint-export -s session.sats | $(PATSOLVE) -i
	$(PATSOPT) -tc --constraint-export -d session.dats | $(PATSOLVE) -i

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
