#include "contrib/libatscc/libatscc2erl/staloadall.hats"

staload "session.sats"
staload "contrib/libatscc/libatscc2erl/basics_erl.sats"

#define ATS_DYNLOADFLAG 0


%{^
%%
-module(server).
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


extern fun server (): void = "mac#"
implement server () = let 
	fun loop (ch: channel (snd string :: rcv string :: cls ())): void = let 
		val _ = send (ch, "hello")
		val ret = receive (ch)
		val _ = println! ret
	in 
		close ch 
	end 

	val name = make_name {snd string :: rcv string :: cls()} ("shared")

in 
	accept (name, llam ch => loop ch)
end 