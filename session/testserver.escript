#!/usr/bin/env escript
%%! -sname a@localhost
main(_) ->
	net_adm:ping(b@localhost),
	net_adm:ping(c@localhost),
	test_link_server:server().
#    'Elixir.Node':connect('b@localhost'),
#    percept:profile("server.dat", {server, server, []}, [procs]),
#    percept:analyze("server.dat"),
#    percept:start_webserver(8888).


