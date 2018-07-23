

OUTPUT=./output/




all: test


prepare:
	cp session.sats session.dats session.ex session.hrl ${OUTPUT}
	cp tests/*.dats ${OUTPUT}

lib: prepare ./session.ex 
	rm -f *.beam
	cd ${OUTPUT} && ERL_COMPILER_OPTIONS=debug_info elixirc session.ex

test: lib tests/teststub.dats session.dats
	cd ${OUTPUT} && patscc -ccats --tlcalopt-disable teststub.dats session.dats
	cd ${OUTPUT} && atscc2erl -i teststub_dats.c session_dats.c > test.erl 
	cd ${OUTPUT} && erlc +debug_info test.erl 

cleanall:
	rm -rf ${OUTPUT}/*.erl ${OUTPUT}/*ats.c ${OUTPUT}/*.beam

z3: prepare tests/teststub.dats
	cd ${OUTPUT} && patsopt -tc --constraint-export -d teststub.dats | patsolve_smt2 -i | tee ./constraints | z3 -t:2000 -smt2 -in 2>&1 | tee output | em -fgreen "^unsat" | em "^sat|^timeout|^unknown" #| grep -B1 "unknown"

