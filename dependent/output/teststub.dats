

#define ATS_DYNLOADFLAG 0
#include "contrib/libatscc2erl/ATS2-0.3.2/staloadall.hats"
#include "queue.dats"

%{^
-module(test).
-compile(nowarn_unused_vars).
-compile(nowarn_unused_function).
-compile(export_all).
-compile(debug_info).
-include("$PATSHOME/contrib/libatscc2erl/ATS2-0.3.2/output/libatscc2erl_all.hrl").
-include("./session.hrl").
%} 


extern fun runtest (): void = "r"
implement runtest () = test ()