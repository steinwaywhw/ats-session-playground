{"filter":false,"title":"server.dats","tooltip":"/server.dats","undoManager":{"mark":91,"position":91,"stack":[[{"group":"doc","deltas":[{"start":{"row":0,"column":0},"end":{"row":152,"column":0},"action":"insert","lines":["","%{^","#include <pthread.h>","%}","","","#include \"share/atspre_staload.hats\"","","staload UNISTD = \"libc/SATS/unistd.sats\"","staload _ = \"libats/DATS/deqarray.dats\"","staload _ = \"libats/DATS/athread.dats\"","staload _ = \"libats/DATS/athread_posix.dats\"","","staload \"$PATSHOMERELOC/contrib/libats-/hwxi/teaching/mysession2SATS/basis.sats\"","staload \"$PATSHOMERELOC/contrib/libats-/hwxi/teaching/mysession2SATS/co-list.sats\"","staload _ = \"$PATSHOMERELOC/contrib/libats-/hwxi/teaching/mysession2/DATS/basis_chan.dats\"","staload _ = \"$PATSHOMERELOC/contrib/libats-/hwxi/teaching/mysession2/DATS/basis_chan2.dats\"","staload _ = \"$PATSHOMERELOC/contrib/libats-/hwxi/teaching/mysession2/DATS/basis_ssntyp.dats\"","staload _ = \"$PATSHOMERELOC/contrib/libats-/hwxi/teaching/mysession2/DATS/co-list.dats\"","","extern fun ints_from (n: int): channeg(sslist(int))","extern fun ints_filter (channeg(sslist(int)), n: int): channeg(sslist(int))","","implement ints_from (n) = let","    fun fserv ( chp: chanpos(sslist(int)), n: int ) : void = let","        val opt = chanpos_list (chp)","    in","        case+ opt of","        | chanpos_list_nil() => chanpos_nil_wait(chp)","        | chanpos_list_cons() => (chanpos_send<int>(chp, n); fserv(chp, n+1))","    end","in","  channeg_create_exn(llam(chp) => fserv(chp, n))","end","","(* ****** ****** *)","","implement ints_filter (chn, n) = let","    fun getfst ( chn: !channeg(sslist(int)) ) : int = let","        val () = channeg_list_cons(chn)","        val fst = channeg_send_val(chn)","    in","        if fst mod n > 0 then fst else getfst(chn)","    end","","    fun fserv ( chp: chanpos(sslist(int)) , chn: channeg(sslist(int)) ) : void = let","        val opt = chanpos_list (chp)","    in","        case+ opt of","        | chanpos_list_nil() => ( chanpos_nil_wait(chp); channeg_list_nil(chn); channeg_nil_close(chn) )","        | chanpos_list_cons() => ( chanpos_send(chp, getfst(chn)); fserv(chp, chn) )","    end ","in","    channeg_create_exn(llam(chp) => fserv(chp, chn))","end","","","extern fun primes_gen(): channeg(sslist(int))","","implement primes_gen() = let ","    fun fserv ( chp: chanpos(sslist(int)) , chn: channeg(sslist(int)) ) : void = let","        val opt = chanpos_list (chp)","    in","    case+ opt of","    | chanpos_list_nil() => ( chanpos_nil_wait(chp); channeg_list_nil(chn); channeg_nil_close(chn) )","    | chanpos_list_cons() => let ","            val () = channeg_list_cons(chn)","            val p0 = channeg_send_val(chn)","        in","            chanpos_send(chp, p0); fserv(chp, ints_filter(chn, p0))","        end","    end","in","    channeg_create_exn(llam(chp) => fserv(chp, ints_from(2)))","end ","","","extern fun fprint_primes (out: FILEref, n: int, chn: !channeg(sslist(int))): void","","implement fprint_primes (out, n, chn) = (","if n > 0 ","then let","        val () = channeg_list_cons(chn)","        val px = channeg_send_val<int> (chn)","        val () = fprintln! (out, px)","    in","        fprint_primes (out, n-1, chn)","    end","else ()",") ","","","fun wait_for_closing (N: int): void = let","","fun log (N: int, n: int, i: int): int = if n >= N then i else log(N, n+n, i+1)","","fun loop ( n: int ) : void =","if n > 0","then let","  val _ = $UNISTD.usleep(250000u)","  val () = fprint(stdout_ref, \".\")","  val () = fileref_flush(stdout_ref)","in","  loop (n-1)","end (*   [if] *)","//","val () = loop(3+log(N/8, 1, 0))","val () = fprint_newline (stdout_ref)","//","in","  // nothing","end //   [wait_for_closing]","","(* ****** ****** *)","","implement","main0(argc, argv) =","{","//","val N =","(","//","if argc >= 2","  then g0string2int(argv[1]) else 10","//",") : int //   [val]","//","val N = g1ofg0(N)","val () = assertloc (N >= 0)","//","val out = stdout_ref","//","val chn = primes_gen()","//","val () = fprint_primes(out, N, chn)","//","val () = channeg_list_nil(chn)","val () = channeg_nil_close(chn)","//","val () =","print!","(","  \"Waiting for the created threads to finish\"",") (*   [val] *)","//","val () = wait_for_closing(N)","//","} (*   [main0] *)","","(* ****** ****** *)","","(*   [sieve.dats] *)",""]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":64},"end":{"row":13,"column":65},"action":"insert","lines":["/"]}]}],[{"group":"doc","deltas":[{"start":{"row":14,"column":64},"end":{"row":14,"column":65},"action":"insert","lines":["/"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":9},"end":{"row":13,"column":10},"action":"insert","lines":["{"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":24},"end":{"row":13,"column":25},"action":"insert","lines":["}"]}]}],[{"group":"doc","deltas":[{"start":{"row":14,"column":9},"end":{"row":14,"column":10},"action":"insert","lines":["{"]}]}],[{"group":"doc","deltas":[{"start":{"row":14,"column":24},"end":{"row":14,"column":25},"action":"insert","lines":["}"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":9},"end":{"row":13,"column":10},"action":"remove","lines":["{"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":10},"end":{"row":13,"column":11},"action":"insert","lines":["{"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":9},"end":{"row":13,"column":25},"action":"remove","lines":["${PATSHOMERELOC}"]},{"start":{"row":13,"column":9},"end":{"row":13,"column":10},"action":"insert","lines":["~"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":11},"end":{"row":13,"column":12},"action":"insert","lines":["/"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":11},"end":{"row":13,"column":12},"action":"remove","lines":["/"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":11},"end":{"row":13,"column":12},"action":"insert","lines":["c"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":12},"end":{"row":13,"column":13},"action":"insert","lines":["o"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":13},"end":{"row":13,"column":14},"action":"insert","lines":["n"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":14},"end":{"row":13,"column":15},"action":"insert","lines":["t"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":15},"end":{"row":13,"column":16},"action":"insert","lines":["r"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":16},"end":{"row":13,"column":17},"action":"insert","lines":["i"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":17},"end":{"row":13,"column":18},"action":"insert","lines":["n"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":18},"end":{"row":13,"column":19},"action":"insert","lines":["/"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":11},"end":{"row":13,"column":18},"action":"remove","lines":["contrin"]},{"start":{"row":13,"column":11},"end":{"row":13,"column":18},"action":"insert","lines":["contrib"]}]}],[{"group":"doc","deltas":[{"start":{"row":18,"column":13},"end":{"row":18,"column":27},"action":"remove","lines":["$PATSHOMERELOC"]},{"start":{"row":18,"column":13},"end":{"row":18,"column":23},"action":"insert","lines":["~/contrib/"]},{"start":{"row":17,"column":13},"end":{"row":17,"column":27},"action":"remove","lines":["$PATSHOMERELOC"]},{"start":{"row":17,"column":13},"end":{"row":17,"column":23},"action":"insert","lines":["~/contrib/"]},{"start":{"row":16,"column":13},"end":{"row":16,"column":27},"action":"remove","lines":["$PATSHOMERELOC"]},{"start":{"row":16,"column":13},"end":{"row":16,"column":23},"action":"insert","lines":["~/contrib/"]},{"start":{"row":15,"column":13},"end":{"row":15,"column":27},"action":"remove","lines":["$PATSHOMERELOC"]},{"start":{"row":15,"column":13},"end":{"row":15,"column":23},"action":"insert","lines":["~/contrib/"]}]}],[{"group":"doc","deltas":[{"start":{"row":18,"column":23},"end":{"row":18,"column":24},"action":"remove","lines":["/"]},{"start":{"row":17,"column":23},"end":{"row":17,"column":24},"action":"remove","lines":["/"]},{"start":{"row":16,"column":23},"end":{"row":16,"column":24},"action":"remove","lines":["/"]},{"start":{"row":15,"column":23},"end":{"row":15,"column":24},"action":"remove","lines":["/"]}]}],[{"group":"doc","deltas":[{"start":{"row":14,"column":9},"end":{"row":14,"column":26},"action":"remove","lines":["{$PATSHOMERELOC}/"]},{"start":{"row":14,"column":9},"end":{"row":14,"column":19},"action":"insert","lines":["~/contrib/"]}]}],[{"group":"doc","deltas":[{"start":{"row":18,"column":13},"end":{"row":18,"column":14},"action":"remove","lines":["~"]},{"start":{"row":18,"column":13},"end":{"row":18,"column":14},"action":"insert","lines":["/"]},{"start":{"row":17,"column":13},"end":{"row":17,"column":14},"action":"remove","lines":["~"]},{"start":{"row":17,"column":13},"end":{"row":17,"column":14},"action":"insert","lines":["/"]},{"start":{"row":16,"column":13},"end":{"row":16,"column":14},"action":"remove","lines":["~"]},{"start":{"row":16,"column":13},"end":{"row":16,"column":14},"action":"insert","lines":["/"]},{"start":{"row":15,"column":13},"end":{"row":15,"column":14},"action":"remove","lines":["~"]},{"start":{"row":15,"column":13},"end":{"row":15,"column":14},"action":"insert","lines":["/"]},{"start":{"row":14,"column":9},"end":{"row":14,"column":10},"action":"remove","lines":["~"]},{"start":{"row":14,"column":9},"end":{"row":14,"column":10},"action":"insert","lines":["/"]},{"start":{"row":13,"column":9},"end":{"row":13,"column":10},"action":"remove","lines":["~"]},{"start":{"row":13,"column":9},"end":{"row":13,"column":10},"action":"insert","lines":["/"]}]}],[{"group":"doc","deltas":[{"start":{"row":18,"column":14},"end":{"row":18,"column":15},"action":"insert","lines":["h"]},{"start":{"row":17,"column":14},"end":{"row":17,"column":15},"action":"insert","lines":["h"]},{"start":{"row":16,"column":14},"end":{"row":16,"column":15},"action":"insert","lines":["h"]},{"start":{"row":15,"column":14},"end":{"row":15,"column":15},"action":"insert","lines":["h"]},{"start":{"row":14,"column":10},"end":{"row":14,"column":11},"action":"insert","lines":["h"]},{"start":{"row":13,"column":10},"end":{"row":13,"column":11},"action":"insert","lines":["h"]}]}],[{"group":"doc","deltas":[{"start":{"row":18,"column":15},"end":{"row":18,"column":16},"action":"insert","lines":["o"]},{"start":{"row":17,"column":15},"end":{"row":17,"column":16},"action":"insert","lines":["o"]},{"start":{"row":16,"column":15},"end":{"row":16,"column":16},"action":"insert","lines":["o"]},{"start":{"row":15,"column":15},"end":{"row":15,"column":16},"action":"insert","lines":["o"]},{"start":{"row":14,"column":11},"end":{"row":14,"column":12},"action":"insert","lines":["o"]},{"start":{"row":13,"column":11},"end":{"row":13,"column":12},"action":"insert","lines":["o"]}]}],[{"group":"doc","deltas":[{"start":{"row":18,"column":16},"end":{"row":18,"column":17},"action":"insert","lines":["m"]},{"start":{"row":17,"column":16},"end":{"row":17,"column":17},"action":"insert","lines":["m"]},{"start":{"row":16,"column":16},"end":{"row":16,"column":17},"action":"insert","lines":["m"]},{"start":{"row":15,"column":16},"end":{"row":15,"column":17},"action":"insert","lines":["m"]},{"start":{"row":14,"column":12},"end":{"row":14,"column":13},"action":"insert","lines":["m"]},{"start":{"row":13,"column":12},"end":{"row":13,"column":13},"action":"insert","lines":["m"]}]}],[{"group":"doc","deltas":[{"start":{"row":18,"column":17},"end":{"row":18,"column":18},"action":"insert","lines":["e"]},{"start":{"row":17,"column":17},"end":{"row":17,"column":18},"action":"insert","lines":["e"]},{"start":{"row":16,"column":17},"end":{"row":16,"column":18},"action":"insert","lines":["e"]},{"start":{"row":15,"column":17},"end":{"row":15,"column":18},"action":"insert","lines":["e"]},{"start":{"row":14,"column":13},"end":{"row":14,"column":14},"action":"insert","lines":["e"]},{"start":{"row":13,"column":13},"end":{"row":13,"column":14},"action":"insert","lines":["e"]}]}],[{"group":"doc","deltas":[{"start":{"row":18,"column":18},"end":{"row":18,"column":19},"action":"insert","lines":["/"]},{"start":{"row":17,"column":18},"end":{"row":17,"column":19},"action":"insert","lines":["/"]},{"start":{"row":16,"column":18},"end":{"row":16,"column":19},"action":"insert","lines":["/"]},{"start":{"row":15,"column":18},"end":{"row":15,"column":19},"action":"insert","lines":["/"]},{"start":{"row":14,"column":14},"end":{"row":14,"column":15},"action":"insert","lines":["/"]},{"start":{"row":13,"column":14},"end":{"row":13,"column":15},"action":"insert","lines":["/"]}]}],[{"group":"doc","deltas":[{"start":{"row":18,"column":19},"end":{"row":18,"column":20},"action":"insert","lines":["u"]},{"start":{"row":17,"column":19},"end":{"row":17,"column":20},"action":"insert","lines":["u"]},{"start":{"row":16,"column":19},"end":{"row":16,"column":20},"action":"insert","lines":["u"]},{"start":{"row":15,"column":19},"end":{"row":15,"column":20},"action":"insert","lines":["u"]},{"start":{"row":14,"column":15},"end":{"row":14,"column":16},"action":"insert","lines":["u"]},{"start":{"row":13,"column":15},"end":{"row":13,"column":16},"action":"insert","lines":["u"]}]}],[{"group":"doc","deltas":[{"start":{"row":18,"column":20},"end":{"row":18,"column":21},"action":"insert","lines":["b"]},{"start":{"row":17,"column":20},"end":{"row":17,"column":21},"action":"insert","lines":["b"]},{"start":{"row":16,"column":20},"end":{"row":16,"column":21},"action":"insert","lines":["b"]},{"start":{"row":15,"column":20},"end":{"row":15,"column":21},"action":"insert","lines":["b"]},{"start":{"row":14,"column":16},"end":{"row":14,"column":17},"action":"insert","lines":["b"]},{"start":{"row":13,"column":16},"end":{"row":13,"column":17},"action":"insert","lines":["b"]}]}],[{"group":"doc","deltas":[{"start":{"row":18,"column":21},"end":{"row":18,"column":22},"action":"insert","lines":["u"]},{"start":{"row":17,"column":21},"end":{"row":17,"column":22},"action":"insert","lines":["u"]},{"start":{"row":16,"column":21},"end":{"row":16,"column":22},"action":"insert","lines":["u"]},{"start":{"row":15,"column":21},"end":{"row":15,"column":22},"action":"insert","lines":["u"]},{"start":{"row":14,"column":17},"end":{"row":14,"column":18},"action":"insert","lines":["u"]},{"start":{"row":13,"column":17},"end":{"row":13,"column":18},"action":"insert","lines":["u"]}]}],[{"group":"doc","deltas":[{"start":{"row":18,"column":22},"end":{"row":18,"column":23},"action":"insert","lines":["n"]},{"start":{"row":17,"column":22},"end":{"row":17,"column":23},"action":"insert","lines":["n"]},{"start":{"row":16,"column":22},"end":{"row":16,"column":23},"action":"insert","lines":["n"]},{"start":{"row":15,"column":22},"end":{"row":15,"column":23},"action":"insert","lines":["n"]},{"start":{"row":14,"column":18},"end":{"row":14,"column":19},"action":"insert","lines":["n"]},{"start":{"row":13,"column":18},"end":{"row":13,"column":19},"action":"insert","lines":["n"]}]}],[{"group":"doc","deltas":[{"start":{"row":18,"column":23},"end":{"row":18,"column":24},"action":"insert","lines":["t"]},{"start":{"row":17,"column":23},"end":{"row":17,"column":24},"action":"insert","lines":["t"]},{"start":{"row":16,"column":23},"end":{"row":16,"column":24},"action":"insert","lines":["t"]},{"start":{"row":15,"column":23},"end":{"row":15,"column":24},"action":"insert","lines":["t"]},{"start":{"row":14,"column":19},"end":{"row":14,"column":20},"action":"insert","lines":["t"]},{"start":{"row":13,"column":19},"end":{"row":13,"column":20},"action":"insert","lines":["t"]}]}],[{"group":"doc","deltas":[{"start":{"row":18,"column":24},"end":{"row":18,"column":25},"action":"insert","lines":["u"]},{"start":{"row":17,"column":24},"end":{"row":17,"column":25},"action":"insert","lines":["u"]},{"start":{"row":16,"column":24},"end":{"row":16,"column":25},"action":"insert","lines":["u"]},{"start":{"row":15,"column":24},"end":{"row":15,"column":25},"action":"insert","lines":["u"]},{"start":{"row":14,"column":20},"end":{"row":14,"column":21},"action":"insert","lines":["u"]},{"start":{"row":13,"column":20},"end":{"row":13,"column":21},"action":"insert","lines":["u"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":8},"end":{"row":13,"column":12},"action":"insert","lines":["    "]}]}],[{"group":"doc","deltas":[{"start":{"row":14,"column":8},"end":{"row":14,"column":12},"action":"insert","lines":["    "]}]}],[{"group":"doc","deltas":[{"start":{"row":22,"column":0},"end":{"row":22,"column":1},"action":"insert","lines":["l"]}]}],[{"group":"doc","deltas":[{"start":{"row":22,"column":1},"end":{"row":22,"column":2},"action":"insert","lines":["s"]}]}],[{"group":"doc","deltas":[{"start":{"row":22,"column":1},"end":{"row":22,"column":2},"action":"remove","lines":["s"]}]}],[{"group":"doc","deltas":[{"start":{"row":22,"column":0},"end":{"row":22,"column":1},"action":"remove","lines":["l"]}]}],[{"group":"doc","deltas":[{"start":{"row":5,"column":0},"end":{"row":5,"column":1},"action":"insert","lines":["/"]}]}],[{"group":"doc","deltas":[{"start":{"row":5,"column":1},"end":{"row":5,"column":2},"action":"insert","lines":["/"]}]}],[{"group":"doc","deltas":[{"start":{"row":5,"column":2},"end":{"row":5,"column":3},"action":"insert","lines":["/"]}]}],[{"group":"doc","deltas":[{"start":{"row":5,"column":3},"end":{"row":5,"column":4},"action":"insert","lines":["/"]}]}],[{"group":"doc","deltas":[{"start":{"row":5,"column":0},"end":{"row":6,"column":0},"action":"remove","lines":["////",""]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":0},"end":{"row":3,"column":2},"action":"remove","lines":["%{^","#include <pthread.h>","%}"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":0},"end":{"row":3,"column":2},"action":"insert","lines":["%{^","#include <pthread.h>","%}"]}]}],[{"group":"doc","deltas":[{"start":{"row":12,"column":0},"end":{"row":14,"column":0},"action":"remove","lines":["staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/basis.sats\"","staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/co-list.sats\"",""]},{"start":{"row":11,"column":0},"end":{"row":13,"column":0},"action":"insert","lines":["staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/basis.sats\"","staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/co-list.sats\"",""]}]}],[{"group":"doc","deltas":[{"start":{"row":11,"column":0},"end":{"row":13,"column":0},"action":"remove","lines":["staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/basis.sats\"","staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/co-list.sats\"",""]},{"start":{"row":10,"column":0},"end":{"row":12,"column":0},"action":"insert","lines":["staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/basis.sats\"","staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/co-list.sats\"",""]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":0},"end":{"row":12,"column":0},"action":"remove","lines":["staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/basis.sats\"","staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/co-list.sats\"",""]},{"start":{"row":9,"column":0},"end":{"row":11,"column":0},"action":"insert","lines":["staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/basis.sats\"","staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/co-list.sats\"",""]}]}],[{"group":"doc","deltas":[{"start":{"row":9,"column":0},"end":{"row":11,"column":0},"action":"remove","lines":["staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/basis.sats\"","staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/co-list.sats\"",""]},{"start":{"row":8,"column":0},"end":{"row":10,"column":0},"action":"insert","lines":["staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/basis.sats\"","staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/co-list.sats\"",""]}]}],[{"group":"doc","deltas":[{"start":{"row":8,"column":0},"end":{"row":10,"column":0},"action":"remove","lines":["staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/basis.sats\"","staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/co-list.sats\"",""]},{"start":{"row":7,"column":0},"end":{"row":9,"column":0},"action":"insert","lines":["staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/basis.sats\"","staload     \"/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/co-list.sats\"",""]}]}],[{"group":"doc","deltas":[{"start":{"row":8,"column":93},"end":{"row":9,"column":0},"action":"insert","lines":["",""]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":0},"end":{"row":3,"column":2},"action":"remove","lines":["%{^","#include <pthread.h>","%}"]},{"start":{"row":1,"column":0},"end":{"row":5,"column":18},"action":"insert","lines":["%{^","//","#include <pthread.h>","//","%} // end of [%{^]"]}]}],[{"group":"doc","deltas":[{"start":{"row":5,"column":3},"end":{"row":5,"column":18},"action":"remove","lines":["// end of [%{^]"]}]}],[{"group":"doc","deltas":[{"start":{"row":4,"column":0},"end":{"row":5,"column":0},"action":"remove","lines":["//",""]}]}],[{"group":"doc","deltas":[{"start":{"row":2,"column":0},"end":{"row":3,"column":0},"action":"remove","lines":["//",""]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":0},"end":{"row":11,"column":0},"action":"remove","lines":["staload UNISTD = \"libc/SATS/unistd.sats\"",""]},{"start":{"row":9,"column":0},"end":{"row":10,"column":0},"action":"insert","lines":["staload UNISTD = \"libc/SATS/unistd.sats\"",""]}]}],[{"group":"doc","deltas":[{"start":{"row":9,"column":0},"end":{"row":10,"column":0},"action":"remove","lines":["staload UNISTD = \"libc/SATS/unistd.sats\"",""]},{"start":{"row":8,"column":0},"end":{"row":9,"column":0},"action":"insert","lines":["staload UNISTD = \"libc/SATS/unistd.sats\"",""]}]}],[{"group":"doc","deltas":[{"start":{"row":8,"column":0},"end":{"row":9,"column":0},"action":"remove","lines":["staload UNISTD = \"libc/SATS/unistd.sats\"",""]},{"start":{"row":7,"column":0},"end":{"row":8,"column":0},"action":"insert","lines":["staload UNISTD = \"libc/SATS/unistd.sats\"",""]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":0},"end":{"row":11,"column":0},"action":"remove","lines":["",""]},{"start":{"row":11,"column":0},"end":{"row":12,"column":0},"action":"insert","lines":["",""]}]}],[{"group":"doc","deltas":[{"start":{"row":11,"column":0},"end":{"row":12,"column":0},"action":"remove","lines":["",""]},{"start":{"row":12,"column":0},"end":{"row":13,"column":0},"action":"insert","lines":["",""]}]}],[{"group":"doc","deltas":[{"start":{"row":12,"column":0},"end":{"row":13,"column":0},"action":"remove","lines":["",""]},{"start":{"row":13,"column":0},"end":{"row":14,"column":0},"action":"insert","lines":["",""]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":0},"end":{"row":15,"column":0},"action":"remove","lines":["","",""]},{"start":{"row":14,"column":0},"end":{"row":16,"column":0},"action":"insert","lines":["","",""]}]}],[{"group":"doc","deltas":[{"start":{"row":14,"column":0},"end":{"row":16,"column":0},"action":"remove","lines":["","",""]},{"start":{"row":15,"column":0},"end":{"row":17,"column":0},"action":"insert","lines":["","",""]}]}],[{"group":"doc","deltas":[{"start":{"row":15,"column":0},"end":{"row":17,"column":0},"action":"remove","lines":["","",""]},{"start":{"row":16,"column":0},"end":{"row":18,"column":0},"action":"insert","lines":["","",""]}]}],[{"group":"doc","deltas":[{"start":{"row":16,"column":0},"end":{"row":18,"column":0},"action":"remove","lines":["","",""]},{"start":{"row":17,"column":0},"end":{"row":19,"column":0},"action":"insert","lines":["","",""]}]}],[{"group":"doc","deltas":[{"start":{"row":0,"column":0},"end":{"row":1,"column":0},"action":"insert","lines":["",""]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":0},"end":{"row":2,"column":0},"action":"insert","lines":["",""]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":0},"end":{"row":1,"column":1},"action":"insert","lines":["s"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":1},"end":{"row":1,"column":2},"action":"insert","lines":["t"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":2},"end":{"row":1,"column":3},"action":"insert","lines":["a"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":3},"end":{"row":1,"column":4},"action":"insert","lines":["l"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":4},"end":{"row":1,"column":5},"action":"insert","lines":["o"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":5},"end":{"row":1,"column":6},"action":"insert","lines":["a"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":6},"end":{"row":1,"column":7},"action":"insert","lines":["d"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":7},"end":{"row":1,"column":8},"action":"insert","lines":[" "]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":8},"end":{"row":1,"column":9},"action":"insert","lines":["\""]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":9},"end":{"row":1,"column":10},"action":"insert","lines":["s"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":10},"end":{"row":1,"column":11},"action":"insert","lines":["e"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":11},"end":{"row":1,"column":12},"action":"insert","lines":["r"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":12},"end":{"row":1,"column":13},"action":"insert","lines":["v"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":13},"end":{"row":1,"column":14},"action":"insert","lines":["e"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":14},"end":{"row":1,"column":15},"action":"insert","lines":["r"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":15},"end":{"row":1,"column":16},"action":"insert","lines":["."]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":16},"end":{"row":1,"column":17},"action":"insert","lines":["s"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":17},"end":{"row":1,"column":18},"action":"insert","lines":["a"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":18},"end":{"row":1,"column":19},"action":"insert","lines":["t"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":19},"end":{"row":1,"column":20},"action":"insert","lines":["s"]}]}],[{"group":"doc","deltas":[{"start":{"row":1,"column":20},"end":{"row":1,"column":21},"action":"insert","lines":["\""]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":13},"end":{"row":10,"column":34},"action":"remove","lines":["/home/ubuntu/contrib/"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":13},"end":{"row":10,"column":14},"action":"insert","lines":["{"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":14},"end":{"row":10,"column":15},"action":"insert","lines":["$"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":15},"end":{"row":10,"column":16},"action":"insert","lines":["C"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":16},"end":{"row":10,"column":17},"action":"insert","lines":["O"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":17},"end":{"row":10,"column":18},"action":"insert","lines":["N"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":18},"end":{"row":10,"column":19},"action":"insert","lines":["T"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":19},"end":{"row":10,"column":20},"action":"insert","lines":["R"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":20},"end":{"row":10,"column":21},"action":"insert","lines":["I"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":21},"end":{"row":10,"column":22},"action":"insert","lines":["B"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":21},"end":{"row":10,"column":22},"action":"remove","lines":["B"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":20},"end":{"row":10,"column":21},"action":"remove","lines":["I"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":19},"end":{"row":10,"column":20},"action":"remove","lines":["R"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":18},"end":{"row":10,"column":19},"action":"remove","lines":["T"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":17},"end":{"row":10,"column":18},"action":"remove","lines":["N"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":16},"end":{"row":10,"column":17},"action":"remove","lines":["O"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":15},"end":{"row":10,"column":16},"action":"remove","lines":["C"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":15},"end":{"row":10,"column":16},"action":"insert","lines":["{"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":15},"end":{"row":10,"column":16},"action":"remove","lines":["{"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":15},"end":{"row":10,"column":16},"action":"insert","lines":["P"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":16},"end":{"row":10,"column":17},"action":"insert","lines":["A"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":17},"end":{"row":10,"column":18},"action":"insert","lines":["T"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":18},"end":{"row":10,"column":19},"action":"insert","lines":["S"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":19},"end":{"row":10,"column":20},"action":"insert","lines":["H"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":20},"end":{"row":10,"column":21},"action":"insert","lines":["O"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":21},"end":{"row":10,"column":22},"action":"insert","lines":["M"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":22},"end":{"row":10,"column":23},"action":"insert","lines":["E"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":23},"end":{"row":10,"column":24},"action":"insert","lines":["R"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":24},"end":{"row":10,"column":25},"action":"insert","lines":["E"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":25},"end":{"row":10,"column":26},"action":"insert","lines":["L"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":26},"end":{"row":10,"column":27},"action":"insert","lines":["O"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":27},"end":{"row":10,"column":28},"action":"insert","lines":["C"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":28},"end":{"row":10,"column":29},"action":"insert","lines":["}"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":29},"end":{"row":10,"column":30},"action":"insert","lines":["/"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":14},"end":{"row":10,"column":15},"action":"remove","lines":["$"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":13},"end":{"row":10,"column":14},"action":"insert","lines":["$"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":14},"end":{"row":10,"column":15},"action":"remove","lines":["{"]}]}],[{"group":"doc","deltas":[{"start":{"row":10,"column":27},"end":{"row":10,"column":28},"action":"remove","lines":["}"]}]}]]},"ace":{"folds":[],"scrolltop":0,"scrollleft":0,"selection":{"start":{"row":19,"column":0},"end":{"row":19,"column":0},"isBackwards":false},"options":{"guessTabSize":true,"useWrapMode":false,"wrapToView":true},"firstLineState":0},"timestamp":1426100198000,"hash":"b6977dedfc2a856a66938e6490b758dc577be577"}