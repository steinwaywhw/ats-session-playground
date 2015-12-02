#include "contrib/libatscc/libatscc2erl/staloadall.hats"

staload "session.sats"
staload "contrib/libatscc/libatscc2erl/basics_erl.sats"

#define ATS_DYNLOADFLAG 0


%{^
%%
-module(client).
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


extern fun client (): void = "mac#"
implement client () = let 

	extern praxi dual (): DUAL (snd string :: rcv string :: cls (), rcv string :: snd string :: cls ())
	
	prval pf1 = dual_base1 ()          (* cls <> cls *)
	prval pf2 = dual_base2 {string} () (* snd string <> rcv string *)
	prval pf3 = dual_comm pf2          (* rcv string <> snd string *)
	prval pf = dual_ind2 (pf2, pf1)    (* snd :: cls <> rcv :: cls *)
	prval pf = dual_ind2 (pf3, pf)     (* rcv :: snd :: cls <> snd :: rcv :: cls *)
	prval pf = dual_comm pf       

	fun loop (ch: channel (rcv string :: snd string :: cls ())): void = let 
		val msg = receive (ch)
		val _ = println! msg
		val _ = send (ch, "world")
	in 
		close ch 
	end 

	val name = make_name {snd string :: rcv string :: cls()} ("shared")

//	prval pf = dual ()
	val ch = request (pf | name)
in 
	loop ch 
end 
