
PATSOPT=patsopt -IATS ${PATSHOMERELOC} -IATS ~/Git/ats-utils
PATSOLVE=patsolve_z3 
PATSCC=patscc -ccats --tlcalopt-disable -IIATS ${PATSHOMERELOC} -IIATS ~/Git/ats-utils
PATSCCTC=patscc -tcats -IIATS ${PATSHOMERELOC} -IIATS ~/Git/ats-utils
ATS2ERL=atscc2erl
ERLC=erlc +debug_info
ELIXIRC=ERL_COMPILER_OPTIONS=debug_info elixirc 

DEPLOY_TARGET=./app/lib
DEPLOY_TARGET_BEAM=./app/_build/dev/lib/test/ebin/


deploy: deploy_test deploy_session

deploy_test: test.dats deploy_session
	$(PATSOPT) -tc --constraint-export -d test.dats | $(PATSOLVE) -i
	$(PATSCC) --constraint-ignore test.dats
	$(ATS2ERL) -i test_dats.c > test.erl 
	$(ERLC) test.erl 
	mkdir -p $(DEPLOY_TARGET_BEAM)
	mv test.beam $(DEPLOY_TARGET_BEAM)
	# mv test.erl $(DEPLOY_TARGET)
	# rm -rf test_dats.c test.erl session.erl

deploy_session: session.dats session.hrl session.ex 
	$(PATSOPT) -tc --constraint-export -d session.dats | $(PATSOLVE) -i
	$(PATSCC) --constraint-ignore session.dats 
	$(ATS2ERL) -i session_dats.c > session.erl
	# mv session.erl $(DEPLOY_TARGET)
	cp session.ex $(DEPLOY_TARGET)
	# rm -rf session_dats.c 


# test: lib test.dats 
	# $(PATSOPT) -tc --constraint-export -d test.dats | $(PATSOLVE) -i
	# $(PATSCC) test.dats
	# $(ATS2ERL) -i test_dats.c > test.erl 
	# $(ERLC) test.erl 
	# rm test.erl

tc: session.sats session.dats
	$(PATSOPT) -tc --constraint-export -s session.sats | $(PATSOLVE) -i
	$(PATSOPT) -tc --constraint-export -d session.dats | $(PATSOLVE) -i
	$(PATSOPT) -tc --constraint-export -d test.dats | $(PATSOLVE) -i


showtype: session.dats 
	$(PATSCC) --constraint-ignore session.dats 
	$(PATSCC) --constraint-ignore test.dats 
	rm session_dats.c test_dats.c
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

testerl: test_datatype.dats 
	$(PATSCC) test_datatype.dats 
	$(ATS2ERL) -i test_datatype_dats.c > test_datatype.erl 	


clean:
	rm -f *.beam 
	rm -f *ats.c 
	rm -f *.erl
