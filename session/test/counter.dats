#include "contrib/libatscc/libatscc2erl/staloadall.hats"

staload "../session.sats"
//staload "contrib/libatscc/libatscc2erl/basics_erl.sats"

#define ATS_DYNLOADFLAG 0


%{^
%%
-module(counter).
%%
-compile(nowarn_unused_vars).
-compile(nowarn_unused_function).
-compile(export_all).
-compile(debug_info).
%%
-include("$PATSHOMERELOC/contrib/libatscc/libatscc2erl/libatscc2erl_all.hrl").
-include("../session.hrl").
%%
%} // end of [%{]

abstype stream (a:t@ype)
assume stream (a:t@ype) = offr (cls (), snd a :: stream a)


abstype dualstream (a:t@ype)
assume dualstream (a:t@ype) = chse (cls (), rcv a :: dualstream a)

extern praxi dual {a:t@ype} (): DUAL (stream a, dualstream a)

extern fun count_from (n: int): name (stream int)

implement count_from (n) = let 
	val name = make_name{stream int} ("counter")

//	fun loop (ch: channel (stream int), n: int): void = let 
//		fun more (ch: channel (snd int :: stream int), n: int) = let 
//			val _ = send (ch, n)
//		in 
//			loop (ch, n+1)
//		end 

//	in 
//		offer (ch, llam ch => close ch, llam ch => more ch)
//	end 

//	val _ = spawn_link (lam () => accept (name, llam ch => loop (ch, 0)))
in 
	name
end
////
extern fun nats (): name (stream int)
implement nats () = count_from 0

extern fun filter (name (stream int), int -> bool): name (stream int)
implement filter (name, f) = let 

	prval pf = dual {int} ()
	val chin = request (pf | name)

	val nname = make_name{stream int} ("filter")

	fun loop (chout: channel (stream int)): void = let 
		fun nomore (chout: channel (cls ())): void = let 
			val _ = close chout 
			val _ = choose_fst chin 
		in 
			close chin 
		end 

		fun more (chout: channel (snd int :: stream int)) = let 
			val _ = choose_snd chin 
			val n = receive chin 
			val _ = if f n then send (chout, n)
		in 
			loop chout
		end 

	in 
		offer (chout, llam ch => nomore ch, llam ch => more ch)
	end 

	val _ = spawn_link (lam () => accept (nname, llam ch => loop ch))
in 
	nname
end

extern fun test (int): void = "mac#"
implement test (n) = let 
	val n = nats ()
	val n2 = filter (n, lam n => n mod 2 = 0)

	prval pf = dual {int} ()
	val ch = request (pf | n2)

	val _ = choose_snd ch 
	val msg = receive ch 
	val _ = println! msg 
in 
	if n > 0
	then test (n-1)
end 
