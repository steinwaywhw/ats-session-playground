#include "contrib/libatscc/libatscc2erl/staloadall.hats"
staload "session.sats"
staload "intset.sats"
staload UN = "prelude/SATS/unsafe.sats"

#define ATS_DYNLOADFLAG 0

%{^
%%
-module(test).
%%
-compile(nowarn_unused_vars).
-compile(nowarn_unused_function).
-compile(export_all).
-compile(debug_info).
%%
%%-include("$PATSHOMERELOC/contrib/libatscc/libatscc2erl/libatscc2erl_all.hrl").
-include("./session.erl").
%%
%} // end of [%{]


//#define ++ proj_seqs 
//#define -+ proj_seqs_skipp 
//infixr (::) ++ 
//infixr (::) -+



(*************************)
local 
(*************************)

prval _ = $solver_assert (set_range_base)
prval _ = $solver_assert (set_range_ind)
prval _ = $solver_assert (set_range_lemma1)
prval _ = $solver_assert (set_range_lemma2)

#define ** rtseqs
infixr (::) **


#define SELLER 0
#define BUYER1 1
#define BUYER2 2
#define BUYER3 3

#define :: seqs
#define PROTO (msg(BUYER1,SELLER,string)::msg(SELLER,BUYER1,int)::msg(SELLER,BUYER2,int)::msg(BUYER1,BUYER2,int)::chse(BUYER2,msg(BUYER2,SELLER,string)::msg(SELLER,BUYER2,string)::cls(),cls()))
#define RT (rtmsg(BUYER1,SELLER)**rtmsg(SELLER,BUYER1)**rtmsg(SELLER,BUYER2)**rtmsg(BUYER1,BUYER2)**rtchse(BUYER2, rtmsg(BUYER2,SELLER)**rtmsg(SELLER,BUYER2)**rtcls(), rtcls()))

#define PROTO2 (msg(BUYER2,BUYER3,int)::msg(BUYER2,BUYER3,session(range(BUYER2,BUYER2),range(0,2),chse(BUYER2,msg(BUYER2,SELLER,string)::msg(SELLER,BUYER2,string)::cls(),cls())))::cls())
#define RT2 (rtmsg(BUYER2,BUYER3)**rtmsg(BUYER2,BUYER3)**rtcls())


#define N 4
#define M 4
typedef MESH = 
	forasc(0, N-2, lam (i:int) => 
		forasc(0, M-2, lam (j:int) => 
			msg(i*M+j, i*M+j+1, int) :: msg(i*M+j, (i+1)*M+j, int)))
	:: forasc(0, M-2, lam (i:int) => msg((N-1)*M+i, (N-1)*M+i+1, int))
	:: forasc(0, N-2, lam (i:int) => msg(i*M+M-1, (i+1)*M+M-1, int))


extern fun inspect {a:t@ype} (a): string = "mac#libsession_inspect"
extern fun debug (string): void = "mac#libsession_debug"
extern fun info (string): void = "mac#libsession_info"
typedef erlval = ERLval

fun set2erl {s:set} (s: set s): erlval = let 
	datatype _set (set) = 
	| Empty (empty_set ()) of ()
	| {s:set} {n:int | ~mem(n, s)} Elem (set_add (s, n)) of (int n, set s)

	assume set (s:set) = _set s

	(* the "f" should be ->, instead of -<cloref1> since it will be given an erlang func directly *)
	fun set_reduce {s:set} (s: set s, base: erlval, f: (int, erlval) -> erlval): erlval = 
		case+ s of 
		| Empty () => base 
		| Elem (n, s) => f (n, set_reduce (s, base, f))

	extern fun _set2erl (set s, (set s, erlval, (int, erlval) -> erlval) -<cloref1> erlval): erlval = "mac#libsession__set2erl"
in 
	_set2erl (s, lam (s, base, f) => set_reduce (s, base, f))
end
extern fun unregister {s:set} (string, erlval): void = "mac#libsession_unregister"

(*************************)
in 
(*************************)


extern fun mesh (): void = "mac#"
implement mesh () = let 

//	val rt = 
//		(rtforasc(0, N-2, lam(i:int) => 
//			rtforasc(0, M-2, lam(j:int) => 
//				rtmsg(i*M+j, i*M+j+1) ** rtmsg(i*M+j, (i+1)*M+j))) 
//		** rtforasc(0, M-2, lam(i:int) => rtmsg((N-1)*M+i, (N-1)*M+i+1)) 
//		** rtforasc(0, N-2, lam(i:int) => rtmsg(i*M+M-1, (i+1)*M+M-1)))
//		: rtsession (MESH)

	val f = lam {i:nat} (i: int i) => rtmsg (0, i)
//	val _ = $showtype f
	val rt = (rtforasc(1,3,f))// : rtsession (forasc(1,3,lam(i:int) => msg(0,i,int)))
//	val rt = $UN.cast{rtsession (MESH)} rt
//	val name = make_name {range(0, M*N-1)} {MESH} (set_range (0, M*N-1), rt, "MESH")

//	val rt = 

//	fun worker {i,j:nat|i < N && j < M} (int i, int j): void = 
//		init(name, set_add(empty_set(), i*M+j), 
//			llam opt => 
//				case+ opt of 
//				| ~Nothing () => info "SESSION INIT FAILED")
//				| ~Just (session) => let 
//					fun {} unroll (n: int): void = 
//						if n > 0 
//						then let val _ = foreach_asc_unroll session in unroll (n-1) end
//						else foreach_asc_done session

//					fun {} flatten_outer (n: int, m: int): void = 
//						if n = 0 
//						then flatten_inner (n, m)
//						else let val _ = flatten_inner (n, m) in flatten_outer (n-1, m) end

//					and {} flatten_inner (n: int, m: int):
//						if m = 0
//						then 
						


//					val _ = unroll (N-2)
//					val _ = unroll (M-2)

in 
end


extern fun a (int): void = "mac#"
implement a (price) =  
	init (name, set_add(empty_set(), SELLER), 
		llam opt => 
			case+ opt of 
			| ~Nothing () => info "nothing"	
			| ~Just (session) => let 
//				val _ = unregister ("test", set2erl(set_add(empty_set(), SELLER)))
				val title = receive (session, BUYER1)
				val _ = info "seller got request for:"
				val _ = info title 
				val _ = info "replying price"
				val _ = info (inspect price)
				val _ = send (session, BUYER1, price)
				val _ = send (session, BUYER2, price)
				val _ = skip_msg session 
				val choice = offer (session, BUYER2)
			in case+ choice of 
				| ~ChooseFst () => let 
						val address = receive (session, BUYER2)
						val _ = info "seller got address"
						val _ = info address 
						val _ = send (session, BUYER2, "tomorrow")
						val _ = info "seller sending date"
					in close session end 
				| ~ChooseSnd () => close session 
			end 
	) where {
		val name = make_name {range(0,2)} {PROTO} (set_range(0,2), RT, "test")
	}


extern fun b (int): void = "mac#"
implement b (contrib) = 
	init (name, set_add(empty_set(), BUYER1), 
		llam opt => 
			case+ opt of 
			| ~Nothing () => info "nothing1"	
			| ~Just (session) => let 
//				val _ = unregister ("test", set2erl(set_add(empty_set(), BUYER1)))

				val _ = info "buyer 1 sending title"
				val _ = send (session, SELLER, "book title")
				val price = receive (session, SELLER)
				val _ = info (inspect price)
				val _ = skip_msg (session)
				val _ = info "buyer 1 sending to buyer2 what he can contribute"
				val _ = send (session, BUYER2, contrib)
				val choice = offer (session, BUYER2)
			in case+ choice of 
			 	| ~ChooseFst () => let 
			 			val _ = skip_msg session 
			 			val _ = skip_msg session 
			 		in close session end 
			 	| ~ChooseSnd () => close session 
			end 
	) where {
		val name = make_name {range(0,2)} {PROTO} (set_range(0,2), RT, "test")
	}


extern fun c (int): void = "mac#"
implement c (budget) = 
	init (name, set_add(empty_set(), BUYER2), 
		llam opt => 
			case+ opt of 
			| ~Nothing () => info "nothing2"	
			| ~Just (session) => let 
				val _ = skip_msg session 
				val _ = skip_msg session 
				val _ = info "buyer 2 received the book price"
				val price = receive (session, SELLER)
				val _ = info (inspect price)
				val _ = info "buyer 2 received what buyer 1 can contribute"
				val contrib = receive (session, BUYER1)
				val _ = info (inspect contrib)
			in 
				if price - contrib > budget
				then let 
					val _ = info "buyer 2 can't afford"
					val _ = choose_snd (session) in close session end 
				else let 
					val _ = choose_fst (session)
					val _ = send (session, SELLER, "my address")
					val date = receive (session, SELLER)
					val _ = info date
				in close session end 
			end 
	) where {
		val name = make_name {range(0,2)} {PROTO} (set_range(0,2), RT, "test")
	}

extern fun c2 (int): void = "mac#"
implement c2 (budget) = 
	init (name, set_add(empty_set(), BUYER2), 
		llam opt => 
			case+ opt of 
			| ~Nothing () => info "nothing2"	
			| ~Just (session) => let 
//				val _ = unregister ("test", set2erl(set_add(empty_set(), BUYER2)))

				val _ = skip_msg session 
				val _ = skip_msg session 
				val price = receive (session, SELLER)
				val _ = info "buyer 2 received price"
				val _ = info (inspect price)
				val _ = info "buyer 2 received what buyer 1 can contribute"
				val contrib = receive (session, BUYER1)
				val _ = info (inspect contrib)
			in 
				if price - contrib > budget
				then let 
						val name = make_name {range(2,3)} {PROTO2} (set_range(2,3), RT2, "test2")
						val _ = info "buyer 2 can't afford, asking buyer 3"
					in 
						init (name, set_range(BUYER2,BUYER2), 
							llam opt => 
								case+ opt of 
								| ~Nothing () => let val _ = choose_snd session in close session end 
								| ~Just (buyer3) => let 
//									val _ = unregister ("test2", set2erl(set_add(empty_set(), BUYER2)))

									val _ = send (buyer3, BUYER3, price - contrib)
									val _ = info "buyer 2 sends to buyer 3 his endpoint"
									val _ = send (buyer3, BUYER3, session)
								in
									close buyer3
								end
						)
					end
				else let 
					val _ = choose_fst (session)
					val _ = send (session, SELLER, "my address")
					val date = receive (session, SELLER)
					val _ = info date
				in close session end 
			end 
	) where {
		val name = make_name {range(0,2)} {PROTO} (set_range(0,2), RT, "test")
	}

extern fun c3 (int): void = "mac#"
implement c3 (budget) = 
	init (name, set_add(empty_set(), BUYER3), 
		llam opt => 
			case+ opt of 
			| ~Nothing() => info "nothing"
			| ~Just (session) => let 
//					val _ = unregister ("test2", set2erl(set_add(empty_set(), BUYER3)))

					val _ = info "buyer 3 received what he needs to pay"
					val price = receive (session, BUYER2): int 
					val _ = info (inspect price)
					val _ = info "buyer 3 received buyer 2's endpoint"
					val buyer2 = receive (session, BUYER2)
					val _ = close session
				in 
					if price <= budget
					then let 
						val _ = info "buyer 3 agreed to pay"
						val _ = choose_fst buyer2
						val _ = info "buyer 3 send address to seller as buyer 2"
						val _ = send (buyer2, SELLER, "my other address")
						val _ = info "buyer 3 received date as buyer 2"
						val date = receive (buyer2, SELLER)
						val _ = info date
						in close buyer2 end
					else let 
						val name = make_name {range(2,3)} {PROTO2} (set_range(2,3), RT2, "test2")
						val _ = info "buyer 2 can't afford, asking buyer 3"
					in 
						init (name, set_range(BUYER2,BUYER2), 
							llam opt => 
								case+ opt of 
								| ~Nothing () => let val _ = choose_snd buyer2 in close buyer2 end
								| ~Just (buyer3) => let 
//									val _ = unregister ("test2", set2erl(set_add(empty_set(), BUYER2)))

									val _ = info "buyer 2 sends to buyer 3 the price he needs to pay"
									val _ = send (buyer3, BUYER3, price - budget)
									val _ = info (inspect (price - budget))
									val _ = info "buyer 2 sends to buyer 3 his endpoint"
									val _ = send (buyer3, BUYER3, buyer2)
								in
									close buyer3
								end
						)
					end
				end
	) where {
		val name = make_name {range(2,3)} {PROTO2} (set_range(2,3), RT2, "test2")
	}

extern fun d (): void = "mac#"
implement d () = let 
	val opt = create (set_range(1,2), set_range(0,0), rtinit(set_range(0,2)) ** RT, 
		llam opt => 
			case+ opt of 
			| ~Nothing () => info "nothing"	
			| ~Just (session) => let 
				val title = receive (session, BUYER1)
				val _ = info title 
				val _ = send (session, BUYER1, 50)
				val _ = send (session, BUYER2, 50)
				val _ = skip_msg session 
				val choice = offer (session, BUYER2)
			in case+ choice of 
				| ~ChooseFst () => let 
						val address = receive (session, BUYER2)
						val _ = info address 
						val _ = send (session, BUYER2, "tomorrow")
					in close session end 
				| ~ChooseSnd () => close session 
			end 
	)
in 
	case+ opt of 
	| ~Nothing () => info "nothing"
	| ~Just (session) => let 
		val _ = send (session, SELLER, "book title")
		val price = receive (session, SELLER)
		val _ = info (inspect ($UN.castvwtp0{int} price))
		val price = receive (session, SELLER)
		val _ = info (inspect ($UN.castvwtp0{int} price))
		val _ = skip_msg session
		val _ = choose_fst session 
		val _ = send (session, SELLER, "my address")
		val date = receive (session, SELLER)
		val _ = info date
	in 
		close session 
	end 
end 

extern fun e (): void = "mac#"
implement e () = let 
	val opt0 = create (set_range(1,2), set_range(0,0), rtinit(set_range(0,2)) ** RT, 
		llam opt => 
			case+ opt of 
			| ~Nothing () => info "nothing"	
			| ~Just (session) => let 
				val title = receive (session, BUYER1)
				val _ = info title 
				val _ = send (session, BUYER1, 50)
				val _ = send (session, BUYER2, 50)
				val _ = skip_msg session 
				val choice = offer (session, BUYER2)
			in case+ choice of 
				| ~ChooseFst () => let 
						val address = receive (session, BUYER2)
						val _ = info address 
						val _ = send (session, BUYER2, "tomorrow")
					in close session end 
				| ~ChooseSnd () => close session 
			end 
	)

	val opt1 = create (set_add(set_add(empty_set(), 0), 2), set_range(1,1), rtinit(set_range(0,2)) ** RT, 
		llam opt => 
			case+ opt of 
			| ~Nothing () => info "nothing1"	
			| ~Just (session) => let 
				val _ = send (session, SELLER, "book title")
				val price = receive (session, SELLER)
				val price = $UN.castvwtp0{int} price
				val _ = info (inspect price)
				val _ = skip_msg (session)
				val _ = send (session, BUYER2, price)
				val choice = offer (session, BUYER2)
			in case+ choice of 
			 	| ~ChooseFst () => let 
			 			val _ = skip_msg session 
			 			val _ = skip_msg session 
			 		in close session end 
			 	| ~ChooseSnd () => close session 
			end 
	)

in 
	case+ (opt0, opt1) of 
	| (~Nothing(), ~Nothing()) => info "nothing after link"
	| (~Just(a), ~Just(b)) => let 
			val session = link (a, b)
			val _ = skip_msg session 
			val _ = skip_msg session 
			val price = receive (session, SELLER)
			val price = $UN.castvwtp0{int} price
			val _ = info (inspect price)
			val contrib = receive (session, BUYER1) :int
		in 
			if contrib < 20 
			then let val _ = choose_snd (session) in close session end 
			else let 
				val _ = choose_fst (session)
				val _ = send (session, SELLER, "my address")
				val date = receive (session, SELLER)
				val _ = info date
			in close session end 
		end 
	| (~Just (a), ~Nothing()) =>> let prval _ = $UN.cast2void a in end
	| (~Nothing (), ~Just(b)) =>> let prval _ = $UN.cast2void b in end
end


(*************************)
end 
(*************************)

