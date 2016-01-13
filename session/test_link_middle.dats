#include "contrib/libatscc/libatscc2erl/staloadall.hats"
staload "session.sats"

#define ATS_DYNLOADFLAG 0


%{^
%%
-module(test_link_middle).
%%
-compile(nowarn_unused_vars).
-compile(nowarn_unused_function).
-compile(export_all).
-compile(debug_info).
%%
-include("$PATSHOMERELOC/contrib/libatscc/libatscc2erl/libatscc2erl_all.hrl").
-include("./session.hrl").
%%
%} // end of [%{]


extern fun proxy {p,q:type} (DUAL (p, q) | channel q): void = "mac#"

implement proxy {p,q} (pf | ch) = let 
	val name = make_name {p} ("mid")
	val chclient = accept name 
in 
	link (pf | chclient, ch)
end 

extern fun upstream (): void = "mac#"
implement upstream () = let 
	prval pf1 = dual_base1 ()          (* cls <> cls *)
	prval pf2 = dual_base2 {string} () (* snd string <> rcv string *)
	prval pf3 = dual_comm pf2          (* rcv string <> snd string *)
	prval pf = dual_ind2 (pf2, pf1)    (* snd :: cls <> rcv :: cls *)
	prval pf = dual_ind2 (pf3, pf)     (* rcv :: snd :: cls <> snd :: rcv :: cls *)
	prval pf = dual_comm pf            (* snd :: rcv :: cls <> rcv :: snd :: cls *)

	prval qf1 = dual_base1 ()          (* cls <> cls *)
	prval qf2 = dual_base2 {int} ()    (* snd int <> rcv int *)
	prval qf = dual_ind2 (qf2, qf1)    (* snd int :: cls <> rcv int :: cls *)

	prval pf = dual_ind1 (pf, qf)      (* offr <> chse *)


	val name = make_name {offr (snd string :: rcv string :: cls (), snd int :: cls ())} ("end")
	val ch = request (pf | name)
in 
	proxy (pf | ch) 
end 
