


# author: Hanwen Wu <steinwaywhw@gmail.com>
# date: 04-11-2017
# 
# This is a revised version


defmodule MyLogger do 
	def log(label, src, dest) do
		pid = Process.whereis(:mylogger)
		if pid == nil do
			pid = spawn_link fn -> loop(1) end
			Process.register(pid, :mylogger)
		end

		send pid, {label, src, dest}
	end

	def loop(counter) do 
		receive do
	 		{label, src, dest} -> 
	 			IO.puts :stderr, "\"#{Kernel.inspect src}\" -> \"#{Kernel.inspect dest}\" [label=\"#{counter}#{Kernel.inspect label}\"]"
	 			loop(counter+1)
		end
	end
end

defmodule Message do 

	@doc """
	Packs a message into a pre-defined format.

	A message is of the format `{label, pid, ref, payload}`, where

	* `label` is the message type
	* `pid` is the message origin, which is the sending endpoint owner's process id
	* `ref` is the message signature, which is the sending endpoint's ref
	* `payload` is the message payload
	"""
	def pack(label, pid, ref, payload) do 
		{label, pid, ref, payload}
	end 

	@doc """
	Inspect a message by converting it to an info string for output.
	"""
	def inspect(msg) do 
		case msg do 
			# {label, pid, ref, payload} -> "#{Kernel.inspect label} #{Kernel.inspect payload} as #{Kernel.inspect ref}"
			{label, pid, ref, payload} -> "#{Kernel.inspect label}"
		end
	end 

	@doc """
	A macro for matching message in the guard expression.

	* `msg`, message to be matched with
	* `label`, the message should have this label
	* `ref`, the message should have this ref 
	"""
	defmacro match(msg, label, ref) do 
		quote do 
			is_tuple(unquote(msg))
			and elem(unquote(msg), 0) == unquote(label)
			and elem(unquote(msg), 2) == unquote(ref)
		end
	end

	@doc """
	A macro for matching message in the guard expression.

	* `msg`, message to be matched with
	* `label`, the message should have this label
	"""	
	defmacro match(msg, label) do 
		quote do 
			is_tuple(unquote(msg))
			and elem(unquote(msg), 0) == unquote(label)
		end
	end  

	@doc """
	Get the label of the message.
	"""
	def label(msg) do 
		case msg do 
			{label, _, _, _} -> label
		end
	end 

	@doc """
	Get the origin(pid) of the message.
	"""
	def origin(msg) do 
		case msg do 
			{_, pid, _, _} -> pid 
		end
	end 

	@doc """
	Get the payload of the message.
	"""
	def payload(msg) do 
		case msg do 
 			{_, _, _, payload} -> payload 
		end
	end 
end

defmodule Channel do 
	
	require Message
	require MyLogger

	@doc """
	The main channel loop.

	* `self`: this endpoint's ref
	* `pid`: the other endpoint's pid 
	* `other`: the other endpoint's ref

	In every iteration, the loop should peek into its mailbox to find and fulfill
	requests from the owning process (thus the message should signed by "self")
	"""
	defp loop(self, pid, other) do 

		# IO.puts :stderr, "loop(#{inspect self}, #{inspect pid}, #{inspect other})"

		receive do


			# :send
			# 
			# The request will be forwarded to the dual endpoint
			req when Message.match(req, :send, self) ->
				# IO.puts :stderr, "-> #{Message.inspect req}"

				# IO.puts :stderr, "#{inspect pid} <- #{Message.inspect req}"
				MyLogger.log(:send, self(), pid)
				send pid, req 

				# sync
				receive do
					reply when Message.match(reply, :receive, other) -> :ok
				end

				loop(self, pid, other)


			# :receive
			# 
			# This endpoint will peek into the mailbox to find the first
			# message that matches {:send, _, other, _}, that is, signed by 
			# the dual endpoint.
			# 
			# Also, this is one of the possible block point. We need to handle :cut
			# as well. According to the state machine, after :cut, we should return to this
			# :receive state. We do this by reply the :receive request.
			req when Message.match(req, :receive, self) ->
				# IO.puts :stderr, "-> #{Message.inspect req}"

				receive do 
					# found :send
					snd when Message.match(snd, :send, other) ->
						# IO.puts :stderr, "-> #{Message.inspect snd}"

						# IO.puts :stderr, "#{inspect Message.origin(req)} <- #{Message.inspect snd}"
						MyLogger.log(:send, self(), Message.origin(req))
						send Message.origin(req), snd

						# sync
						send pid, req

						loop(self, pid, other)

					# found :link
					link when Message.match(link, :link, other) ->
						# IO.puts :stderr, "-> #{Message.inspect link}"

						# the request message is consumed
						# need to replay current request by putting it back
						# into the mailbox
						# IO.puts :stderr, "#{inspect self()} <- #{Message.inspect req}"
						MyLogger.log(:receive, self(), self())
						send self(), req

						# start the new loop with new dual endpoint
						{newpid, newother} = Message.payload link 
						loop(self, newpid, newother)
				end 



			# :close
			# 
			# This is an synchronous version. 
			# It simply closes.
			req when Message.match(req, :close, self) ->
				# IO.puts :stderr, "-> #{Message.inspect req}"
				nil 


			# :offer
			# 
			# This is another blocking point, we need to handle :link
			# as well.
			# req when Message.match(req, :offer, self) ->
			# 	IO.puts :stderr, "-> #{Message.inspect req}"

			# 	receive do 
			# 		# found :choose
			# 		choice when Message.match(choice, :choose, other) ->
			# 			IO.puts :stderr, "-> #{Message.inspect choice}"

			# 			IO.puts :stderr, "#{inspect Message.origin(req)} <- #{Message.inspect choice}"
			# 			send Message.origin(req), choice

			# 			loop(self, pid, other)

			# 		# found :link
			# 		link when Message.match(link, :link, other) -> 
			# 			IO.puts :stderr, "-> #{Message.inspect link}"

			# 			IO.puts :stderr, "#{inspect self()} <- #{Message.inspect req}"
			# 			send self(), req 

			# 			{newpid, newother} = Message.payload link 
			# 			loop(self, newpid, newother) 			
			# 	end 



			# :choose
			# 
			# Just forward the request
			# req when Message.match(req, :choose, self) ->
			# 	IO.puts :stderr, "-> #{Message.inspect req}"

			# 	IO.puts :stderr, "#{inspect pid} <- #{Message.inspect req}"
			# 	send pid, req

			# 	loop(self, pid, other)
 
			# :link
			# 
			# Say the owning process is trying to link two endpoints, A and B. Then,
			# 
			# * A will receive B's pid and ref, B will receive A's pid and ref
			# * A will send B the info of A's dual, B will send A the info of B's dual
			# * A will forward B's dual to A's dual, B will forward A's dual to B's dual
			# * A will forward any remaining message to B as if A is the B's owning process
			# * B will forward any remaining message to A as if B is the A's owning process
			req when Message.match(req, :link, self) ->
				# IO.puts :stderr, "-> #{Message.inspect req}"
 
 				# receive B's pid and ref
				{pid_b, ref_b} = Message.payload req 

				# send A's dual to B
				out = Message.pack(:link, Message.origin(req), self, {pid, other})
				# IO.puts :stderr, "#{inspect pid_b} <- #{Message.inspect out}"
				MyLogger.log(:link, self(), pid_b)
				send pid_b, out 

				receive do 
					# receive B's dual
					reply when Message.match(reply, :link, ref_b) -> 
						# IO.puts :stderr, "-> #{Message.inspect reply}"

						# forward B's dual to A's dual
						{pid_b_dual, ref_b_dual} = Message.payload(reply)

						out = Message.pack(:link, Message.origin(reply), self, Message.payload(reply))
						# IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
						MyLogger.log(:link, self(), pid)
						send pid, out


						# At this point, A/B's dual should have entered the new loop, and is blocked in 
						# one of the blocking points. Or A/B's dual has closed. 
						# 
						# Also, at this point, A/B's owning process should have no requests left in A/B's 
						# mailbox, since the endpoints are already consumed.
						# 
						# Need to forward any remaining messages (signed by `other`) to B (not B's dual), 
						# and forward any messages from B (signed by `ref_b_dual`) to A's dual.
						forward({self(), self}, {pid_b, ref_b}, {pid, other}, {pid_b_dual, ref_b_dual})
						send self(), Message.pack(:close, self(), self, nil)
				end

			# When :link is the only message, but it is from the other endpoint
			# we need to switch to a new loop with a new dual endpoint
			# without replaying any message, because there's no need
			link when Message.match(link, :link, other) ->
				{newpid, newother} = Message.payload link 
				loop(self, newpid, newother)
		end

		# IO.puts :stderr, "#{inspect self()} CLOSED"
	end 


	defp forward(a, b, a_dual, b_dual) do 
		{_, len} = :erlang.process_info(self(), :message_queue_len)

		{pid_a, ref_a} = a
		{pid_b, ref_b} = b 
		{pid_a_dual, ref_a_dual} = a_dual 
		{pid_b_dual, ref_b_dual} = b_dual 

		if len > 0 do 
			receive do 
				# when the message is signed by `ref_a_dual`
				# it should be forwarded to B
				{label, pid, ^ref_a_dual, payload} -> 
					# IO.puts :stderr, "FORWARDING -> #{inspect label} #{inspect payload}"

					out = Message.pack(label, pid, ref_a_dual, payload)
					# IO.puts :stderr, "FORWARDING #{inspect pid_b} <- #{Message.inspect out} as #{inspect ref_a_dual}"
					MyLogger.log(:forward, self(), pid_b)
					send pid_b, out

					forward(a, b, a_dual, b_dual)

				# when the message is signed by `ref_b_dual`
				# it should be forwarded to A's dual
				{label, pid, ^ref_b_dual, payload} -> 
					# IO.puts :stderr, "FORWARDING -> #{inspect label} #{inspect payload}"

					out = Message.pack(label, pid, ref_b_dual, payload)
					# IO.puts :stderr, "FORWARDING #{inspect pid_a_dual} <- #{Message.inspect out} as #{inspect ref_b_dual}"
					MyLogger.log(:forward, self(), pid_a_dual)
					send pid_a_dual, out

					forward(a, b, a_dual, b_dual)
			end 
		end 
	end


	defp init() do 
		receive do 
			{:init, _, {self, pid, other}} ->
				# IO.puts :stderr, "-> :init"
				loop(self, pid, other)
		end 
	end 

	@doc """
	Create a channel represented by two of its ends.

	Every channel has two ends, and two refs. 
	Every end runs in its own thread.
	Channel is `{self_pid, self_ref, other_end_ref}`
	"""
	def channel_create() do

		# make two refs and two ends of the channel 
		ref_a = make_ref()
		ref_b = make_ref()
		pid_a = spawn_link fn -> init() end
		pid_b = spawn_link fn -> init() end
		
		to_a = {:init, self(), {ref_a, pid_b, ref_b}}
		to_b = {:init, self(), {ref_b, pid_a, ref_a}}

		# IO.puts :stderr, "#{inspect pid_a} <- #{inspect to_a}"
		# IO.puts :stderr, "#{inspect pid_b} <- #{inspect to_b}"
		
		MyLogger.log(:init, self(), pid_a)
		MyLogger.log(:init, self(), pid_b)

		send pid_a, to_a
		send pid_b, to_b

		# return two ends and refs of the channel
		{{pid_a, ref_a}, {pid_b, ref_b}}
	end

	@doc """
	Send a message through this end of the channel.
	"""
	def channel_send(channel, msg) do
		{pid, ref} = channel 
		 
		out = Message.pack(:send, self(), ref, msg)
		# IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
		MyLogger.log(:send, self(), pid)
		send pid, out
	end

	@doc """
	Receive a message from this end of the channel.

	This is done by sending a `{:receive}` message to this end of the channel.
	"""
	def channel_receive(channel) do 
		{pid, ref} = channel

		out = Message.pack(:receive, self(), ref, nil)
		# IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
		MyLogger.log(:receive, self(), pid)
		send pid, out
		
		receive do 
			# send
			msg when Message.match(msg, :send) -> 
				# IO.puts :stderr, "-> #{Message.inspect msg}"
				Message.payload msg
		end 
	end

	@doc """
	Offering a choice.

	1. Send a `{:offer}` to this end of the channel.
	2. It will be forwarded to the other end.
	3. The other end will send a `{:choose}` back.
	4. Now we will receive the `{:choose}` from this end of the channel.
	"""
	# def channel_offer(channel, fn_a, fn_b) do 
	# 	{pid, ref} = channel 

	# 	out = Message.pack(:offer, self(), ref, nil)
	# 	IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
	# 	send pid, out	

	# 	receive do 
	# 		msg when Message.match(msg, :choose) ->
	# 			IO.puts :stderr, "-> #{Message.inspect msg}"

	# 			case Message.payload(msg) do 
	# 				0 -> fn_a.(channel)
	# 				1 -> fn_b.(channel)
	# 			end 
	# 	end 
	# end


	@doc """
	Link two channels dual ends, as bidirectional forwarding.
	"""
	def channel_link(channel_a, channel_b) do 
		{pid_a, ref_a} = channel_a 
		{pid_b, ref_b} = channel_b

		to_a = Message.pack(:link, self(), ref_a, channel_b)
		# IO.puts :stderr, "#{inspect pid_a} <- #{Message.inspect to_a}"
		MyLogger.log(:link, self(), pid_a)
		send pid_a, to_a

		to_b = Message.pack(:link, self(), ref_b, channel_a)
		# IO.puts :stderr, "#{inspect pid_b} <- #{Message.inspect to_b}"
		MyLogger.log(:link, self(), pid_b)
		send pid_b, to_b
	end

	# defp channel_choose(channel, choice) do 
	# 	{pid, ref} = channel 
	# 	out = Message.pack(:choose, self(), ref, choice)
	# 	IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
	# 	send pid, out
	# end 

	# def channel_choose_fst(channel) do 
	# 	channel_choose(channel, 0)
	# end 

	# def channel_choose_snd(channel) do 
	# 	channel_choose(channel, 1)
	# end

	def channel_close(channel) do 
		{pid, ref} = channel 
		out = Message.pack(:close, self(), ref, nil)
		# IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
		MyLogger.log(:close, self(), pid)
		send pid, out 
	end
end 

