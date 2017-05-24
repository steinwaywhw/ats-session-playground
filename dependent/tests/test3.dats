////
staload "../session.sats"
staload UN = "prelude/SATS/unsafe.sats"


#define :: pseq


#define C 1 
#define S 0

//stadef ints = (pfix2 (lam (p:int->protocol):int->protocol => lam n => pmsg(S,int n)::p(n+1)))
stadef ints = 
	(pfix2 (
		lam (p:int->protocol):int->protocol => 
			lam n => pmsg(S,int n)::pquan(S,lam(m:int):protocol=>p(m))))

//stadef ints2 = (pfix3 (lam (p:(int,int)->protocol):(int,int)->protocol => lam (n,m) => pmsg(S,int n)::p(n,m)))

extern fun from {n:int} (int n): chan (C, ints n)
implement from {n} (n) = let 
	fun server {n:int} (chan: chan (S, ints n), n: int n): void = let 
		val _ = recurse2 {S} {lam (p:int->protocol):int->protocol => lam n => pmsg(S,int n)::pquan(S,lam(m:int):protocol=>p(m))} {n} chan
		val _ = send (chan, n)
		val _ = unify chan
		val _ = $showtype chan
	in 
		server (chan, n)
	end
in 
	create (llam (chan) => server (chan, n))
end


////
S2Eapp(S2Eapp(S2Ecst(pfix2); S2Elam(p; S2Elam(n; S2Eapp(S2Ecst(pseq); S2Eapp(S2Ecst(pmsg); S2Eintinf(0), S2Eapp(S2Ecst(g1int_int_t0ype); S2Eextkind(atstype_int), S2Evar(n(4487)))), S2Eapp(S2Ecst(pquan); S2Eintinf(0), S2Elam(m; S2Eapp(S2Evar(p); S2Evar(m)))))))); S2EVar(8)); 
S2Eapp(S2Eapp(S2Ecst(pfix2); S2Elam(p; S2Elam(n; S2Eapp(S2Ecst(pseq); S2Eapp(S2Ecst(pmsg); S2Eintinf(0), S2Eapp(S2Ecst(g1int_int_t0ype); S2Eextkind(atstype_int), S2Evar(n(4484)))), S2Eapp(S2Ecst(pquan); S2Eintinf(0), S2Elam(m; S2Eapp(S2Evar(p); S2Evar(m)))))))); S2Eapp(S2Ecst(add_int_int); S2Evar(n(4455)), S2Eintinf(1)))))

////



extern fun filter {n:int} (chan (C, ints n)): #[m:int|m mod n != 0] chan (C, ints2 (n, m))


////

implement filter (chan, p) = let 
	fun get (chan: !ints(C)): int = let 
		val _ = recurse chan 
		val _ = choose (chan, Left ())
		val n = recv chan 
	in 
		if p n
		then n 
		else get chan
	end

	fun server (out: ints(S), inp: ints(C)): void = let 
		val _ = recurse out 
		val c = offer out 
	in 
		case+ c of 
		| ~Left() => (send (out, get inp); server (out, inp))
		| ~Right() => (wait out; recurse inp; choose (inp, Right()); close inp)
	end
in 
	create (llam (out) => server (out, chan))
end 

//extern fun sieve (ints C): ints C
implement sieve (inp) = let 



