



% libsession_make_name(Name)                 -> 'Elixir.Session':make_name('Elixir.List':to_string(Name)).

% libsession_request(Name, Gp, Self, Arity)  -> 'Elixir.Session':request(Name, Gp, Self, Arity).
% libsession_accept(Name, Check, Self, Task) -> 'Elixir.Session':accept(Name, ats2erlpre_cloref2fun1(Check), Self, ats2erlpre_cloref2fun1(Task)).


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


libsession_unregister(Name, Self)
	-> 'Elixir.NameServer':unregister(Name, Self).

% libsession_send(Payload, To, Session)      -> 'Elixir.Endpoint':send(Payload, To, Session).
% libsession_receive(From, Session)          -> 'Elixir.Endpoint':recv(From, Session).



% libsession_offer(From, Session)            -> 'Elixir.Endpoint':offer(From, Session).
% libsession_choose(Choice, Session)         -> 'Elixir.Endpoint':choose(Choice, Session).
% libsession_choose_fst(Channel)           -> 'Elixir.Channel':channel_choose_fst(Channel).
% libsession_choose_snd(Channel)           -> 'Elixir.Channel':channel_choose_snd(Channel).

% libsession_close(Session)                  -> 'Elixir.Endpoint':close(Session).
% libsession_link(ChnA, ChnB)			           -> 'Elixir.Channel':channel_link(ChnA, ChnB).

% libsession_spawn_link(Clo)			            -> 'Elixir.Kernel':spawn_link(ats2erlpre_cloref2fun0(Clo)).