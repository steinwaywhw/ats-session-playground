


libsession_spawn(F)
	-> 'Elixir.Kernel':spawn(ats2erlpre_cloref2fun0(F)).

libsession_spawn_link(F)
	-> 'Elixir.Kernel':spawn_link(ats2erlpre_cloref2fun0(F)).

libsession_make_ref()
	-> 'Elixir.Kernel':make_ref().

libsession__set2erl(Set, F) 
	-> 'Elixir.Utils':set2erl(Set, ats2erlpre_cloref2fun3(F)).

libsession__init(Name, Self, Parts, Gp) 
	-> 'Elixir.Session':init(Name, Self, Parts, Gp).

libsession__close(Session) 
	-> 'Elixir.Endpoint':close(Session).

libsession_debug(String)
	-> 'Elixir.Utils':debug(String).

libsession_info(String)
	-> 'Elixir.Utils':info(String).

libsession_inspect(Anything)
	-> 'Elixir.Utils':tostring(Anything).

libsession__send(Session, To, Payload) 
	-> 'Elixir.Endpoint':send(Session, To, Payload).

libsession__recv(Session, From)  
	-> 'Elixir.Endpoint':recv(Session, From).

libsession__link(SessionA, SessionB)
	-> 'Elixir.Endpoint':link(SessionA, SessionB). 

libsession__offer(Session, From) 
	-> 'Elixir.Endpoint':offer(Session, From). 
libsession__choose(Session, Choice)
	-> 'Elixir.Endpoint':choose(Session, Choice).

