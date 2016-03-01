
staload UN = "prelude/SATS/unsafe.sats"

datavtype option (a:vt@ype) = 
| Some (a) of a 
| None (a) 


extern fun test (): void = "mac#"
implement test () = () where {
	val a = 1
	val option = Some a
	val- ~Some(a) = option 
	val _ = $UN.cast2void a
}