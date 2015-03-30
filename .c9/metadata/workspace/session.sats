{"changed":true,"filter":false,"title":"session.sats","tooltip":"/session.sats","value":"\n\ndatasort process =\n    | snd of (vt@ype, process)\n    | rcv of (vt@ype, process)\n    | dual of process\n    | nil of () \n    \nabsvtype session (process)\n\nfun {a:vt@ype} send {p:process} (!session (snd (a, p)) >> session p, a): void \nfun {a:vt@ype} receive {p:process} (!session (rcv (a, p)) >> session p): a\n\nfun wait (session nil): void \nfun close (session nil): void\nfun create {p:process} (session (p) -<lincloptr1> void): session (dual p)\nfun connect {p:process} (session (p) -<lincloptr1> void): session (dual p)\n\n////\n\nfun client (session (snd (int, rcv (int, nil))), \n\n////\n\ndatavtype zmq_channel (session\n\n\nimplement create {p:type} (server)\n\n\n    val ctx = zmq_contex_new()\n    val socket = zmq_socket()\n    val _ = zmq_bind (socket)\n    \nin \n    asdlkajsdlkj\nend\n\n\ntypedef serverproto = rpt (int) :: snd (string) :: nil \ntypedef clientproto = snd (int) :: rcv (string) :: nil \n\nfun server {p:type} (s: session (bind: string):\n\n\n\ndatavtype process = \n    | Inactive of ()\n    | Receive of (a:vt@ype, process)\n    | Send of (a:vt@ype, process)\n    \nabsvtype session (process)\n\nfun {a:vt@ype} send (!session (Send (a, p)","undoManager":{"mark":19,"position":100,"stack":[[{"group":"doc","deltas":[{"start":{"row":10,"column":45},"end":{"row":10,"column":46},"action":"insert","lines":["d"]}]}],[{"group":"doc","deltas":[{"start":{"row":11,"column":46},"end":{"row":11,"column":50},"action":"remove","lines":["Recv"]},{"start":{"row":11,"column":46},"end":{"row":11,"column":47},"action":"insert","lines":["r"]}]}],[{"group":"doc","deltas":[{"start":{"row":11,"column":47},"end":{"row":11,"column":48},"action":"insert","lines":["c"]}]}],[{"group":"doc","deltas":[{"start":{"row":11,"column":48},"end":{"row":11,"column":49},"action":"insert","lines":["v"]}]}],[{"group":"doc","deltas":[{"start":{"row":15,"column":66},"end":{"row":15,"column":70},"action":"remove","lines":["Dual"]},{"start":{"row":15,"column":66},"end":{"row":15,"column":67},"action":"insert","lines":["d"]}]}],[{"group":"doc","deltas":[{"start":{"row":15,"column":67},"end":{"row":15,"column":68},"action":"insert","lines":["u"]}]}],[{"group":"doc","deltas":[{"start":{"row":15,"column":68},"end":{"row":15,"column":69},"action":"insert","lines":["a"]}]}],[{"group":"doc","deltas":[{"start":{"row":15,"column":69},"end":{"row":15,"column":70},"action":"insert","lines":["l"]}]}],[{"group":"doc","deltas":[{"start":{"row":16,"column":67},"end":{"row":16,"column":71},"action":"remove","lines":["Dual"]},{"start":{"row":16,"column":67},"end":{"row":16,"column":68},"action":"insert","lines":["d"]}]}],[{"group":"doc","deltas":[{"start":{"row":16,"column":68},"end":{"row":16,"column":69},"action":"insert","lines":["u"]}]}],[{"group":"doc","deltas":[{"start":{"row":16,"column":69},"end":{"row":16,"column":70},"action":"insert","lines":["a"]}]}],[{"group":"doc","deltas":[{"start":{"row":16,"column":70},"end":{"row":16,"column":71},"action":"insert","lines":["l"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":18},"end":{"row":13,"column":19},"action":"remove","lines":["N"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":18},"end":{"row":13,"column":19},"action":"remove","lines":["i"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":18},"end":{"row":13,"column":19},"action":"insert","lines":["n"]}]}],[{"group":"doc","deltas":[{"start":{"row":13,"column":19},"end":{"row":13,"column":20},"action":"insert","lines":["i"]}]}],[{"group":"doc","deltas":[{"start":{"row":14,"column":19},"end":{"row":14,"column":20},"action":"remove","lines":["N"]}]}],[{"group":"doc","deltas":[{"start":{"row":14,"column":19},"end":{"row":14,"column":20},"action":"insert","lines":["b"]}]}],[{"group":"doc","deltas":[{"start":{"row":14,"column":19},"end":{"row":14,"column":20},"action":"remove","lines":["b"]}]}],[{"group":"doc","deltas":[{"start":{"row":14,"column":19},"end":{"row":14,"column":20},"action":"insert","lines":["n"]}]}],[{"group":"doc","deltas":[{"start":{"row":19,"column":0},"end":{"row":19,"column":1},"action":"remove","lines":["c"]}]}],[{"group":"doc","deltas":[{"start":{"row":19,"column":0},"end":{"row":19,"column":1},"action":"remove","lines":["o"]}]}],[{"group":"doc","deltas":[{"start":{"row":19,"column":0},"end":{"row":19,"column":1},"action":"remove","lines":["n"]}]}],[{"group":"doc","deltas":[{"start":{"row":19,"column":0},"end":{"row":19,"column":1},"action":"remove","lines":["s"]}]}],[{"group":"doc","deltas":[{"start":{"row":19,"column":0},"end":{"row":19,"column":1},"action":"remove","lines":[" "]}]}],[{"group":"doc","deltas":[{"start":{"row":19,"column":0},"end":{"row":19,"column":1},"action":"remove","lines":["("]}]}],[{"group":"doc","deltas":[{"start":{"row":19,"column":0},"end":{"row":20,"column":0},"action":"insert","lines":["",""]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":0},"end":{"row":21,"column":0},"action":"insert","lines":["",""]}]}],[{"group":"doc","deltas":[{"start":{"row":21,"column":0},"end":{"row":21,"column":2},"action":"insert","lines":["妇女"]}]}],[{"group":"doc","deltas":[{"start":{"row":21,"column":1},"end":{"row":21,"column":2},"action":"remove","lines":["女"]}]}],[{"group":"doc","deltas":[{"start":{"row":21,"column":0},"end":{"row":21,"column":1},"action":"remove","lines":["妇"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":0},"end":{"row":21,"column":0},"action":"remove","lines":["",""]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":0},"end":{"row":20,"column":1},"action":"insert","lines":["f"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":1},"end":{"row":20,"column":2},"action":"insert","lines":["u"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":2},"end":{"row":20,"column":3},"action":"insert","lines":["n"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":3},"end":{"row":20,"column":4},"action":"insert","lines":[" "]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":4},"end":{"row":20,"column":5},"action":"insert","lines":["c"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":5},"end":{"row":20,"column":6},"action":"insert","lines":["l"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":6},"end":{"row":20,"column":7},"action":"insert","lines":["i"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":7},"end":{"row":20,"column":8},"action":"insert","lines":["e"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":8},"end":{"row":20,"column":9},"action":"insert","lines":["n"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":9},"end":{"row":20,"column":10},"action":"insert","lines":["t"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":10},"end":{"row":20,"column":11},"action":"insert","lines":[" "]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":11},"end":{"row":20,"column":12},"action":"insert","lines":["{"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":12},"end":{"row":20,"column":13},"action":"insert","lines":["p"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":13},"end":{"row":20,"column":14},"action":"insert","lines":[":"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":14},"end":{"row":20,"column":15},"action":"insert","lines":["p"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":15},"end":{"row":20,"column":16},"action":"insert","lines":["r"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":16},"end":{"row":20,"column":17},"action":"insert","lines":["o"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":17},"end":{"row":20,"column":18},"action":"insert","lines":["c"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":18},"end":{"row":20,"column":19},"action":"insert","lines":["e"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":19},"end":{"row":20,"column":20},"action":"insert","lines":["s"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":20},"end":{"row":20,"column":21},"action":"insert","lines":["s"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":20},"end":{"row":20,"column":21},"action":"remove","lines":["s"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":19},"end":{"row":20,"column":20},"action":"remove","lines":["s"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":18},"end":{"row":20,"column":19},"action":"remove","lines":["e"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":17},"end":{"row":20,"column":18},"action":"remove","lines":["c"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":16},"end":{"row":20,"column":17},"action":"remove","lines":["o"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":15},"end":{"row":20,"column":16},"action":"remove","lines":["r"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":14},"end":{"row":20,"column":15},"action":"remove","lines":["p"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":13},"end":{"row":20,"column":14},"action":"remove","lines":[":"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":12},"end":{"row":20,"column":13},"action":"remove","lines":["p"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":11},"end":{"row":20,"column":12},"action":"remove","lines":["{"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":11},"end":{"row":20,"column":12},"action":"insert","lines":["("]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":12},"end":{"row":20,"column":13},"action":"insert","lines":["s"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":13},"end":{"row":20,"column":14},"action":"insert","lines":["e"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":14},"end":{"row":20,"column":15},"action":"insert","lines":["s"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":15},"end":{"row":20,"column":16},"action":"insert","lines":["s"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":16},"end":{"row":20,"column":17},"action":"insert","lines":["i"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":17},"end":{"row":20,"column":18},"action":"insert","lines":["o"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":18},"end":{"row":20,"column":19},"action":"insert","lines":["n"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":19},"end":{"row":20,"column":20},"action":"insert","lines":[" "]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":20},"end":{"row":20,"column":21},"action":"insert","lines":["("]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":21},"end":{"row":20,"column":22},"action":"insert","lines":["s"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":22},"end":{"row":20,"column":23},"action":"insert","lines":["n"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":23},"end":{"row":20,"column":24},"action":"insert","lines":["d"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":24},"end":{"row":20,"column":25},"action":"insert","lines":[" "]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":25},"end":{"row":20,"column":26},"action":"insert","lines":["("]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":26},"end":{"row":20,"column":27},"action":"insert","lines":["i"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":27},"end":{"row":20,"column":28},"action":"insert","lines":["n"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":28},"end":{"row":20,"column":29},"action":"insert","lines":["t"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":29},"end":{"row":20,"column":30},"action":"insert","lines":[","]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":30},"end":{"row":20,"column":31},"action":"insert","lines":[" "]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":31},"end":{"row":20,"column":32},"action":"insert","lines":["r"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":32},"end":{"row":20,"column":33},"action":"insert","lines":["c"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":33},"end":{"row":20,"column":34},"action":"insert","lines":["v"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":34},"end":{"row":20,"column":35},"action":"insert","lines":[" "]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":35},"end":{"row":20,"column":36},"action":"insert","lines":["("]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":36},"end":{"row":20,"column":37},"action":"insert","lines":["i"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":37},"end":{"row":20,"column":38},"action":"insert","lines":["n"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":38},"end":{"row":20,"column":39},"action":"insert","lines":["t"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":39},"end":{"row":20,"column":40},"action":"insert","lines":[","]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":40},"end":{"row":20,"column":41},"action":"insert","lines":[" "]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":41},"end":{"row":20,"column":42},"action":"insert","lines":["n"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":42},"end":{"row":20,"column":43},"action":"insert","lines":["i"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":43},"end":{"row":20,"column":44},"action":"insert","lines":["l"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":44},"end":{"row":20,"column":45},"action":"insert","lines":[")"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":45},"end":{"row":20,"column":46},"action":"insert","lines":[")"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":46},"end":{"row":20,"column":47},"action":"insert","lines":[")"]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":47},"end":{"row":20,"column":48},"action":"insert","lines":[","]}]}],[{"group":"doc","deltas":[{"start":{"row":20,"column":48},"end":{"row":20,"column":49},"action":"insert","lines":[" "]}]}]]},"ace":{"folds":[],"scrolltop":0,"scrollleft":0,"selection":{"start":{"row":32,"column":29},"end":{"row":32,"column":29},"isBackwards":false},"options":{"guessTabSize":true,"useWrapMode":false,"wrapToView":true},"firstLineState":0},"timestamp":1427125582106}