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


#define ++ proj_seqs 
#define -+ proj_seqs_skipp 
infixr (::) ++ 
infixr (::) -+

#define ** rtseqs
infixr (::) **

extern fun a (): void = "mac#"
implement a () = let 

	val name = make_name {msg(0,1,int) :: msg(1,2,int) :: msg(2,0,int) :: msg(0,~1,bool) :: chse (2,cls(),msg(2,~1,string)::cls())} ("test")
	fun loop (s: option (session (0, msg(0,1,int)::msg(2,0,int)::msg(0,~1,bool)::chse(2,cls(),msg(2,0,string)::cls())))): void = 
		case+ s of 
		| ~None () => ()
		| ~Some (session) => let 
			val _ = send (session, 1, 10)
			val x = receive (session, 2)
			val _ = broadcast (session, if x = 10 then true else false)
			val choice = offer (session, 2)
			//if ...
			//then broadcast 
			//else broadcast
		in 
			case+ choice of 
			| ChooseFst () => close session 
			| ChooseSnd () => let 
				val msg = receive (session, 2)
				val _ = println! msg 
			in 
				close session 
			end
		end

	val gp = rtmsg(0,1) ** rtmsg(1,2) ** rtmsg(2,0) ** rtmsg(0,~1) ** rtchse (2, rtcls(), rtmsg(2,~1) ** rtcls())

	prval pf = proj_msg_from() ++ proj_msg_skip() -+ proj_msg_to() ++ proj_msg_broadcast_from() ++ proj_chse(proj_cls(), proj_msg_broadcast_to() ++ proj_cls())
in 
	accept (pf | name, 0, gp, llam session => loop session)
end 
//
extern fun b (): void = "mac#"
implement b () = let 

	val name = make_name {msg(0,1,int) :: msg(1,2,int) :: msg(2,0,int) :: msg(0,~1,bool) :: chse(2,cls(),msg(2,~1,string)::cls())} ("test")
	fun loop (s: option (session (1, msg(0,1,int)::msg(1,2,int)::msg(0,1,bool)::chse(2,cls(),msg(2,1,string)::cls())))): void = 
		case+ s of 
		| ~None () => ()
		| ~Some (session) => let 
			val x = receive (session, 0)
			val _ = send (session, 2, x)
			val ret = receive (session, 0)
			val _ = println! ret
			val choice = offer (session, 2)
		in 
			case+ choice of 
			| ChooseFst () => close session
			| ChooseSnd () => let 
				val msg = receive (session, 2)
				val _ = println! msg 
			in 
				close session 
			end
		end

	val gp = rtmsg(0,1) ** rtmsg(1,2) ** rtmsg(2,0) ** rtmsg(0,~1) ** rtchse (2, rtcls(), rtmsg(2,~1) ** rtcls())

	prval pf = proj_msg_to() ++ proj_msg_from() ++ proj_msg_skip() -+ proj_msg_broadcast_to() ++ proj_chse(proj_cls(), proj_msg_broadcast_to() ++ proj_cls())
in 
	accept (pf | name, 1, gp, llam session => loop session)
end 

extern fun c (): void = "mac#"
implement c () = let 

	val name = make_name {msg(0,1,int) :: msg(1,2,int) :: msg(2,0,int) :: msg(0,~1,bool) :: chse(2,cls(),msg(2,~1,string)::cls())} ("test")
	fun loop (s: option (session (2, msg(1,2,int)::msg(2,0,int)::msg(0,2,bool)::chse(2,cls(),msg(2,~1,string)::cls())))): void = 
		case+ s of 
		| ~None () => ()
		| ~Some (session) => let 
			val x = receive (session, 1)
			val _ = send (session, 0, x)
			val ret = receive (session, 0)
			val _ = println! ret
			val _ = choose_snd (session)
			val _ = broadcast (session, "Hello")
		in 
			close session
		end

	val gp = rtmsg(0,1) ** rtmsg(1,2) ** rtmsg(2,0) ** rtmsg(0,~1) ** rtchse (2, rtcls(), rtmsg(2,~1) ** rtcls())

	prval pf = proj_msg_skip() -+ proj_msg_to() ++ proj_msg_from() ++ proj_msg_broadcast_to() ++ proj_chse(proj_cls(), proj_msg_broadcast_from() ++ proj_cls())
in 
	loop (request (pf | name, 2, gp, 3))
end 


