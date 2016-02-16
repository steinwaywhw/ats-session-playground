#include "contrib/libatscc/libatscc2erl/staloadall.hats"
staload "draft.sats"

#define ATS_DYNLOADFLAG 0

#include "draft.dats"

%{^
%%
-module(test).
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


extern fun a (): void = "mac#"
implement a () = let 

	val name = make_name {msg(0,1,int) :: cls()} ("test")
	fun loop (s: option (session (0, msg(0,1,int) :: cls()))): void = 
		case+ s of 
		| ~None () => ()
		| ~Some (session) => let 
			val _ = send (session, 1)
		in 
			close session
		end
in 
	accept (proj_seqs(proj_msg_from(), proj_cls()) | name, 0, rtseqs(rtmsg(0,1), rtcls()), llam session => loop session)
end 

extern fun b (): void = "mac#"
implement b () = let 
	val name = make_name {cls()} ("test")
	fun loop (s: option (session (1, cls()))): void = 
		case+ s of 
		| ~None () => ()
		| ~Some (session) => close session
in 
	accept (proj_cls() | name, 1, rtcls(), llam session => loop session)
end 

extern fun c (): void = "mac#"
implement c () = let 
	val name = make_name {cls()} ("test")
	val session = request (proj_cls() | name, 2, rtcls(), 3)
in
	case+ session of 
	| ~None () => ()
	| ~Some (session) => close session  
end 


