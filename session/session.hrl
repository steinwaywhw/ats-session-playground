



libsession_make_name(Name)    -> 'Elixir.Session':make_name('Elixir.List':to_string(Name)).

libsession_request(Name)      -> 'Elixir.Session':request(Name).
libsession_accept(Name, Clo)  -> 'Elixir.Session':accept(Name, ats2erlpre_cloref2fun1(Clo)).
libsession_send(Channel, Msg) -> 'Elixir.Channel':channel_send(Channel, Msg).
libsession_receive(Channel)   -> 'Elixir.Channel':channel_receive(Channel).


% libsession_offer      {p,q:type} (channel (offr (p, q)), channel p -<linclo1> void, channel q -<linclo1> void
% libsession_choose_fst {p,q:type} (!channel (chse (p, q)) >> channel p
% libsession_choose_snd {p,q:type} (!channel (chse (p, q)) >> channel q

libsession_close(Channel)     -> 'Elixir.Channel':channel_close(Channel).
