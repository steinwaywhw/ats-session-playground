defmodule App do
	require NameServer
	require :test

	def init() do 
		Node.connect :a@localhost
		Node.connect :b@localhost
		Node.connect :c@localhost
		Node.connect :d@localhost
		Node.connect :e@localhost

		nodes = [node() | Node.list()]
		Enum.each nodes, fn node -> 
			:rpc.call(node, Application, :ensure_all_started, [:gproc])
			:rpc.call(node, :gproc_dist, :start_link, [nodes])
		end 

		# :observer.start
		# :rpc.call(:a@localhost, :test, :a, [])
		# :rpc.call(:b@localhost, :test, :b, [])
		# :rpc.call(:c@localhost, :test, :c, [])
	end 


	def test() do 
		require Logger 

		receive do 
			:a -> Logger.info :a 
			:b -> Logger.info :b 
		end 
	end 

	def main(part) do 
		
		NameServer.register(:hello, part, self())
		all = NameServer.await(:hello, [0])

		all
	end
end
