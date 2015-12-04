#include "contrib/libatscc/libatscc2erl/staloadall.hats"

staload "session.sats"
staload "contrib/libatscc/libatscc2erl/basics_erl.sats"

#define ATS_DYNLOADFLAG 0


%{^
%%
-module(nats).
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



