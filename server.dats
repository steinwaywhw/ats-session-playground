
staload "server.sats"

%{^
#include <pthread.h>
%} 

#include "share/atspre_staload.hats"

staload UNISTD = "libc/SATS/unistd.sats"
staload     "/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/basis.sats"
staload     "/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/SATS/co-list.sats"
staload _ = "libats/DATS/deqarray.dats"
staload _ = "libats/DATS/athread.dats"
staload _ = "libats/DATS/athread_posix.dats"
staload _ = "/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/DATS/basis_chan.dats"
staload _ = "/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/DATS/basis_chan2.dats"
staload _ = "/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/DATS/basis_ssntyp.dats"
staload _ = "/home/ubuntu/contrib/contrib/libats-/hwxi/teaching/mysession2/DATS/co-list.dats"



extern fun ints_from (n: int): channeg(sslist(int))
extern fun ints_filter (channeg(sslist(int)), n: int): channeg(sslist(int))

implement ints_from (n) = let
    fun fserv ( chp: chanpos(sslist(int)), n: int ) : void = let
        val opt = chanpos_list (chp)
    in
        case+ opt of
        | chanpos_list_nil() => chanpos_nil_wait(chp)
        | chanpos_list_cons() => (chanpos_send<int>(chp, n); fserv(chp, n+1))
    end
in
  channeg_create_exn(llam(chp) => fserv(chp, n))
end

(* ****** ****** *)

implement ints_filter (chn, n) = let
    fun getfst ( chn: !channeg(sslist(int)) ) : int = let
        val () = channeg_list_cons(chn)
        val fst = channeg_send_val(chn)
    in
        if fst mod n > 0 then fst else getfst(chn)
    end

    fun fserv ( chp: chanpos(sslist(int)) , chn: channeg(sslist(int)) ) : void = let
        val opt = chanpos_list (chp)
    in
        case+ opt of
        | chanpos_list_nil() => ( chanpos_nil_wait(chp); channeg_list_nil(chn); channeg_nil_close(chn) )
        | chanpos_list_cons() => ( chanpos_send(chp, getfst(chn)); fserv(chp, chn) )
    end 
in
    channeg_create_exn(llam(chp) => fserv(chp, chn))
end


extern fun primes_gen(): channeg(sslist(int))

implement primes_gen() = let 
    fun fserv ( chp: chanpos(sslist(int)) , chn: channeg(sslist(int)) ) : void = let
        val opt = chanpos_list (chp)
    in
    case+ opt of
    | chanpos_list_nil() => ( chanpos_nil_wait(chp); channeg_list_nil(chn); channeg_nil_close(chn) )
    | chanpos_list_cons() => let 
            val () = channeg_list_cons(chn)
            val p0 = channeg_send_val(chn)
        in
            chanpos_send(chp, p0); fserv(chp, ints_filter(chn, p0))
        end
    end
in
    channeg_create_exn(llam(chp) => fserv(chp, ints_from(2)))
end 


extern fun fprint_primes (out: FILEref, n: int, chn: !channeg(sslist(int))): void

implement fprint_primes (out, n, chn) = (
if n > 0 
then let
        val () = channeg_list_cons(chn)
        val px = channeg_send_val<int> (chn)
        val () = fprintln! (out, px)
    in
        fprint_primes (out, n-1, chn)
    end
else ()
) 


fun wait_for_closing (N: int): void = let

fun log (N: int, n: int, i: int): int = if n >= N then i else log(N, n+n, i+1)

fun loop ( n: int ) : void =
if n > 0
then let
  val _ = $UNISTD.usleep(250000u)
  val () = fprint(stdout_ref, ".")
  val () = fileref_flush(stdout_ref)
in
  loop (n-1)
end (*   [if] *)
//
val () = loop(3+log(N/8, 1, 0))
val () = fprint_newline (stdout_ref)
//
in
  // nothing
end //   [wait_for_closing]

(* ****** ****** *)

implement
main0(argc, argv) =
{
//
val N =
(
//
if argc >= 2
  then g0string2int(argv[1]) else 10
//
) : int //   [val]
//
val N = g1ofg0(N)
val () = assertloc (N >= 0)
//
val out = stdout_ref
//
val chn = primes_gen()
//
val () = fprint_primes(out, N, chn)
//
val () = channeg_list_nil(chn)
val () = channeg_nil_close(chn)
//
val () =
print!
(
  "Waiting for the created threads to finish"
) (*   [val] *)
//
val () = wait_for_closing(N)
//
} (*   [main0] *)

(* ****** ****** *)

(*   [sieve.dats] *)
