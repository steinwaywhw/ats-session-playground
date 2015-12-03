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

//	extern praxi dual (): DUAL (snd string :: rcv string :: cls (), rcv string :: snd string :: cls ())
	
//offr (
//	snd string :: rcv string :: cls (), 
//	snd int :: cls ())

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

	fun case2 (ch: channel (rcv int :: cls ())): void = let 
		val msg = receive (ch)
		val _ = println! msg
	in 
		close ch 
	end 

	fun case1 (ch: channel (rcv string :: snd string :: cls ())): void = let 
		val msg = receive (ch)
		val _ = println! msg
		val _ = send (ch, "world")
	in 
		close ch 
	end 

	fun loop (ch: channel (chse (rcv string :: snd string :: cls (), rcv int :: cls ()))): void = let 
		val _ = choose_snd ch 
	in 
		case2 ch 
	end 

	val name = make_name {offr (snd string :: rcv string :: cls (), snd int :: cls ())} ("shared")

//	prval pf = dual ()
	val ch = request (pf | name)
in 
	loop ch 
end 
