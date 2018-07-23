%.tc: %.dats
	patsopt -tc --constraint-export -d $< | patsolve_smt2 --println "(declare-sort stype 0)" -i | tee ./constraints | z3 -t:2000 -smt2 -in 2>&1 | tee output | em -fgreen "^unsat" | em "^sat|^timeout|^unknown" 
