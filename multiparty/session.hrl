



libsession_make_name(Name)                 -> 'Elixir.Session':make_name('Elixir.List':to_string(Name)).

libsession_request(Name, Gp, Self, Arity)  -> 'Elixir.Session':request(Name, Gp, Self, Arity).
libsession_accept(Name, Check, Self, Task) -> 'Elixir.Session':accept(Name, ats2erlpre_cloref2fun1(Check), Self, ats2erlpre_cloref2fun1(Task)).
libsession_send(Payload, To, Session)      -> 'Elixir.Endpoint':send(Payload, To, Session).
libsession_receive(From, Session)          -> 'Elixir.Endpoint':recv(From, Session).


libsession_offer(From, Session)            -> 'Elixir.Endpoint':offer(From, Session).
libsession_choose(Choice, Session)         -> 'Elixir.Endpoint':choose(Choice, Session).
% libsession_choose_fst(Channel)           -> 'Elixir.Channel':channel_choose_fst(Channel).
% libsession_choose_snd(Channel)           -> 'Elixir.Channel':channel_choose_snd(Channel).

libsession_close(Session)                  -> 'Elixir.Endpoint':close(Session).
% libsession_link(ChnA, ChnB)			           -> 'Elixir.Channel':channel_link(ChnA, ChnB).

% libsession_spawn_link(Clo)			            -> 'Elixir.Kernel':spawn_link(ats2erlpre_cloref2fun0(Clo)).