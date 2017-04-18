






all: test

lib: session.ex 
	rm -f *.beam
	ERL_COMPILER_OPTIONS=debug_info elixirc session.ex

test: lib teststub.dats session.dats
	patscc -ccats --tlcalopt-disable teststub.dats session.dats
	atscc2erl -i teststub_dats.c session_dats.c > test.erl 
	erlc +debug_info test.erl 
	# rm test.erl 




z3: quantification.dats
	patsopt -tc --constraint-export -d $< | patsolve_smt2 -i | tee ./constraints | z3 -t:2000 -smt2 -in 2>&1 | tee output #| em -fgreen "^unsat" | em "^sat|^timeout|^unknown" #| grep -B1 "unknown"
