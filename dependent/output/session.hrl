



% libsession_make_name(Name)            -> 'Elixir.Session':make_name('Elixir.List':to_string(Name)).

% libsession_request(Name)              -> 'Elixir.Session':request(Name).
% libsession_accept(Name, Clo)          -> 'Elixir.Session':accept(Name, ats2erlpre_cloref2fun1(Clo)).
% libsession_accept(Name)     		  -> 'Elixir.Session':accept(Name).

libsession__create()             -> 'Elixir.Channel':channel_create().
libsession__send(Channel, Msg)   -> 'Elixir.Channel':channel_send(Channel, Msg).
libsession__recv(Channel)        -> 'Elixir.Channel':channel_receive(Channel).
libsession__offer(Channel)       -> 'Elixir.Channel':channel_receive(Channel).
libsession__choose(Channel, Msg) -> 'Elixir.Channel':channel_send(Channel, Msg).

libsession__close(Channel)       -> 'Elixir.Channel':channel_close(Channel).
libsession__wait(Channel)        -> 'Elixir.Channel':channel_close(Channel).

libsession__cut(ChnA, ChnB)		 -> 'Elixir.Channel':channel_link(ChnA, ChnB).

libsession__spawn_link(Clo)      -> 'Elixir.Kernel':spawn_link(ats2erlpre_cloref2fun0(Clo)).

