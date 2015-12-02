#!/usr/bin/env escript
%%! -sname a@localhost
main(_) ->
    'Elixir.Node':connect('b@localhost'),
    percept:profile("server.dat", {server, server, []}, [procs]),
    percept:analyze("server.dat"),
    percept:start_webserver(8888).


