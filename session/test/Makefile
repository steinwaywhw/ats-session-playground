PATSCC=patscc -ccats --tlcalopt-disable -IIATS ${PATSHOMERELOC}
PATSCCTC=patscc -tcats -IIATS ${PATSHOMERELOC}
ERLC=erlc +debug_info
ELIXIRC=ERL_COMPILER_OPTIONS=debug_info elixirc 

counter: counter.dats 
	$(PATSCC) counter.dats
	atscc2erl -i counter_dats.c > counter.erl 
	$(ERLC) counter.erl 
	rm counter.erl

clean:
	rm -f *.beam 
	rm -f *ats.c 
	rm -f *.dat 
