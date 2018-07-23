
#include "share/atspre_staload.hats"
#include "contrib/libatscc/libatscc2erl/staloadall.hats"
staload UN = "prelude/SATS/unsafe.sats"

staload "intset.sats"

absvtype channel (type)
abstype msg ()
abstype cls ()

datavtype session (a:type) = Session (a) of (channel a)


extern fun make (): session(msg()) = "mac#"
extern fun change (!channel(msg()) >> channel(cls())): void = "mac#" 
extern fun close (channel(cls())): void = "mac#"

extern fun test (): void = "mac#"
implement test () = () where {
	val s = make ()
	val+ @Session(channel) = s
	val _ = change channel 
	prval _ = fold@s


	val+ ~Session(channel) = s 
	val _ = close channel

//	prval _ = fold@s
//	val _ = $UN.cast2void s


	val b = $tup (1, 2, 3, 4, 5)
	val c = $rec {x=1, y=2}

	extern fun reduce {s:set} {a:t@ype} (set s, (set s, a, (int, a) -<cloref1> a) -<cloref1> a): void = "abc"

	val _ = reduce(set_range(0,10), lam (s, base, f) => base)
//	val e = $list_vt {int} (1, 2, 3)
//	val f = (arrayptr)$arrpsz{int} (1, 2, 3)
//	val _ = $UN.cast2void f
	val c = ref_vt{int}(0)
	val _ = c[] := 1
	val _ = ref_vt_getfree_elt c

//	val _ = $UN.cast2void b


//	val c = ref<int>(0)
}