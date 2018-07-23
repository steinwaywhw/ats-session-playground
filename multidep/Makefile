


PATSOLVE=patsolve_smt2 --printfile ./set.smt2 -i
PATSOPT=patsopt



typecheck: 
	patsopt -tc --constraint-export -d session.dats | $(PATSOLVE) | tee ./constraints | z3 -smt2 -in
