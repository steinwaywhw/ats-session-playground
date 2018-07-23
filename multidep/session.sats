staload "./set.sats"

sortdef stype = type
sortdef role  = nat
sortdef roles = set

abstype msg    (int, int, vt@ype)
abstype msg    (int, roles, vt@ype)
abstype msg    (int, vt@ype)
abstype seq    (stype, stype)
abstype nil    (int)
abstype branch (int, stype, stype)
abstype branch (int, stype, stype, stype)

#define :: seq

typedef roles (rs:roles) = set rs




datatype stype (stype) = 
| {r1,r2:role} {v:vt@ype} {s:stype} Msg (msg (r1, r2, v) :: s) of (int r1, int r2, stype s)
| {r:role} {v:t@ype} {s:stype} Msg (msg (r, v) :: s)           of (int r, stype s)
| {s,t:stype} Seq (s :: t)                                     of (stype s, stype t)
| {r:role} Nil (nil r)                                         of (int r)
| {r:role} {s1,s2:stype} Branch (branch (r, s1, s2))           of (int r, stype s1, stype s2)
| {r:role} {s1,s2,s3:stype} Branch (branch (r, s1, s2, s3))    of (int r, stype s1, stype s2, stype s3)

datatype flattype (t@ype) =
| INT (int) 
| STRING (string)
| BOOL (bool)
| CHAR (char)

datatype flatvtype (vt@ype) = 
| {t:t@ype} FLATTYPE (t) of flattype t
| {s:stype} STYPE (s) of stype s

absvtype chan (roles, stype) = ptr

fun get_type {rs:roles} {s:stype} (!chan(rs,s)): stype s
fun get_roles {rs:roles} {s:stype} (!chan(rs,s)): roles rs


fun create {self:roles} {s:stype} (roles self, stype s, chan(~self,s) -<lincloptr1> void): chan(self,s)

fun send_one
	{self:roles} {from,to:role|mem(self,from)*not(mem(self,to))} {v:vt@ype} {s:stype} 
	(!chan(self,msg(from,to,v)::s) >> chan(self,s), v): void

fun send_all
	{self:roles} {from:role|mem(self,from)} {v:t@ype} {s:stype} 
	(!chan(self,msg(from,v)::s) >> chan(self,s), v): void

fun receive_one
	{self:roles} {from,to:role|not(mem(self,from))*mem(self,to)} {v:vt@ype} {s:stype}
	(!chan(self,msg(from,to,v)::s) >> chan(self,s)): v

fun receive_all
	{self:roles} {from:role|not(mem(self,from))} {v:t@ype} {s:stype}
	(!chan(self,msg(from,v)::s) >> chan(self,s)): v


fun close {self:roles} {r:role|mem(self,r)} (chan(self,nil(r))): void
fun wait {self:roles} {r:role|not(mem(self,r))} (chan(self,nil(r))): void


fun cut_residual {rs1,rs2:roles|(~rs1)*(~rs2)==emp} {s:stype} (chan(rs1,s), chan(rs2,s)): chan(rs1*rs2,s)