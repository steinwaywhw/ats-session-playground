#!/usr/bin/env escript
%%! -sname b@localhost
main(_) ->
    percept:profile("client.dat", {client, client, []}, [procs]),
    percept:analyze("client.dat").


