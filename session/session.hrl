



libsession_make_name(Name)            -> 'Elixir.Session':make_name('Elixir.List':to_string(Name)).

libsession_request(Name)              -> 'Elixir.Session':request(Name).
libsession_accept(Name, Clo)          -> 'Elixir.Session':accept(Name, ats2erlpre_cloref2fun1(Clo)).
libsession_send(Channel, Msg)         -> 'Elixir.Channel':channel_send(Channel, Msg).
libsession_receive(Channel)           -> 'Elixir.Channel':channel_receive(Channel).


libsession_offer(Channel, CloA, CloB) -> 'Elixir.Channel':channel_offer(Channel, ats2erlpre_cloref2fun1(CloA), ats2erlpre_cloref2fun1(CloB)).
libsession_choose_fst(Channel)        -> 'Elixir.Channel':channel_choose_fst(Channel).
libsession_choose_snd(Channel)        -> 'Elixir.Channel':channel_choose_snd(Channel).

libsession_close(Channel)             -> 'Elixir.Channel':channel_close(Channel).
