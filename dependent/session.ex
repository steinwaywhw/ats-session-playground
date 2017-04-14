


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


	defp delegate_loop(self, dual, sub) do 
		{dualpid, dualref} = dual 
		{subpid, subref} = sub 

		receive do 
			req when Message.match(req, :send, self) ->
				# MyLogger.log(:send, self(), dualpid)
				send dualpid, req 
				delegate_loop(self, dual, sub)
		
			req when Message.match(req, :receive, self) ->

				{_, messages} = :erlang.process_info(self(), :messages)
				has_it = List.foldl(messages, false, fn(msg, acc) -> acc or Message.match(msg, :send, dualref) end)

				if has_it do 
					receive do 
						snd when Message.match(snd, :send, dualref) ->
							# MyLogger.log(:received, self(), Message.origin(req))
							send Message.origin(req), snd
							delegate_loop(self, dual, sub)
					end
				else 
					# MyLogger.log(:delegate_receive, self(), subpid)
					send subpid, req
					delegate_loop(self, dual, sub)
				end
				

				

			req when Message.match(req, :close, self) ->
				# MyLogger.log(:delegate_close, self(), subpid)
				send subpid, req

				:closed 

			# :delegate is telling an endpoint to enter the 
			# delegate mode, by adding a third argument, sub-mailbox, to the loop
			# req when Message.match(req, :delegate, dualref) -> 
				# propogate :delegate to all subs
				# MyLogger.log(:delegate_delegate, self(), subpid)
				# send subpid, req

				# delegate_loop(self, dual, sub)

			# :mailbox is turning an endpoint into someone else's 
			# sub-mailbox, by changing `self` to the new owner's ref
			
			# req when Message.match(req, :mailbox) -> 
			# 	{_, newref} = Message.payload req 

			# 	# propogate :mailbox to all subs
			# 	MyLogger.log(:mailbox, self(), subpid)
			# 	send subpid, req

			# 	delegate_loop(newref, dual, sub)


			# Delegate to the last sub
			# 
			# Say we are trying to link [B] and [C], and this is in [B] now.
			# The last sub [a] will send out 
			# 
			# - :mailbox(signed as Bref) to [C] 
			# - and :delegate(signed as Bref) to [A]
			# 
			# And [B] merely delegates the :link to [a]. [B] will also receive 
			# :mailbox(signed as Cref) from [d], which is handled separately.
			# 
			#          <=>
			# [A]<=>[B]   [C]<=>[D]
			#  |     |     |     |
			# [b]   [a]   [d]   [c]
			req when Message.match(req, :link, self) ->

				# change :link to :delegate_link
				MyLogger.log(:delegate_link, self(), subpid)
				out = Message.pack(:delegate_link, Message.origin(req), self, Message.payload(req)) 
				send subpid, out

				{cpid, cref} = Message.payload req 

				# since it is top level, send delegate to [b]
				MyLogger.log(:delegate, self(), dualpid)
				send dualpid, Message.pack(:delegate, self(), self, Message.payload(req))

				receive do 
					mailbox when Message.match(mailbox, :mailbox, cref) -> 
						{_, newref} = Message.payload req 

						# propogate :mailbox to all subs
						MyLogger.log(:mailbox, self(), subpid)
						send subpid, req

						delegate_loop(newref, dual, sub)
				end

			req when Message.match(req, :delegate_link, self) ->

				MyLogger.log(:delegate_link, self(), subpid)
				send subpid, req 

				{cpid, cref} = Message.payload req 

				receive do 
					mailbox when Message.match(mailbox, :mailbox, cref) -> 
						{_, newref} = Message.payload req 

						# propogate :mailbox to all subs
						MyLogger.log(:mailbox, self(), subpid)
						send subpid, req

						delegate_loop(newref, dual, sub)
				end
		end

	end

	@doc """
	The main channel loop.

	* `self`: this endpoint's ref
	* `dual`: the other endpoint's pid and ref

	In every iteration, the loop should peek into its mailbox to find and fulfill
	requests from the owning process (thus the message should signed by "self").
	"""
	defp loop(self, dual) do 

		{dualpid, dualref} = dual

		receive do

			# :send
			# 
			# The send request will always come from its owner, 
			# before or after a link. 
			# 
			# The request will be forwarded to the dual endpoint, 
			# before or after a link.
			req when Message.match(req, :send, self) ->
				# MyLogger.log(:send, self(), dualpid)
				send dualpid, req 
				loop(self, dual)


			# :receive
			# 
			# There are two cases.
			# 
			# CASE 1: normal
			# * got request from `self`
			# * try to find a message of :send, from `other`
			# * deliver it to the requester
			# 
			# CASE 2: turned into :delegate
			# * got request from `self`
			# * found :delegate instead
			# * turn to :delegate mode and reply :receive. 
			# 
			# Note that, Because it is blocked at :receive, it should have no other
			# requests from the owner. It is safe to reply the :receive request.
			# 
			req when Message.match(req, :receive, self) ->

				receive do 
					# found :send
					# Case 1
					snd when Message.match(snd, :send, dualref) ->
						# MyLogger.log(:received, self(), Message.origin(req))
						send Message.origin(req), snd
						loop(self, dual)

					# found :delegate
					# Case 2
					delegate when Message.match(delegate, :delegate, dualref) ->
						{mboxpid, mboxref} = Message.payload delegate 

						# replay the :receive request
						# MyLogger.log(:replay_receive, self(), self())
						send self(), req

						# switch to delegate mode
						delegate_loop(self, dual, Message.payload delegate)
				end 


			req when Message.match(req, :delegate, dualref) ->
				{mboxpid, mboxref} = Message.payload req 

				# switch to delegate mode
				delegate_loop(self, dual, Message.payload req)

			# :close
			# 
			# This is an synchronous version. 
			# It simply closes.
			req when Message.match(req, :close, self) ->
				:closed  

			# :link at the last sub
			# 
			# Say we are trying to link [B] and [C], and this is in [a] now.
			# As the last sub-mailbox, [a] will receive,
			# 
			# - :link(signed as Bref), with info about [C]
			# 
			# and [a] will send,
			# 
			# - :mailbox(signed as Bref) about info of [A] to [C] 
			# - and :delegate(signed as Bref) about info of [C] to [A]
			# 
			# [a] will receive a :mailbox(signed as Cref) about info of [D], 
			# which is handled elsewhere.
			# 
			#          <=>
			# [A]<=>[B]   [C]<=>[D]
			#  |     |     |     |
			# [b]   [a]   [d]   [c]
			req when Message.match(req, :link, self) ->
 
 				# receive [C]'s pid and ref
				{cpid, cref} = Message.payload req 

				# send [A] to [C] so that [C] turns into a sub-mailbox of [A]
				out = Message.pack(:mailbox, Message.origin(req), self, dual)
				MyLogger.log(:mailbox, self(), cpid)
				send cpid, out 

				# send :delegate to [A] so that [A] can delegate :receive to [C]
				MyLogger.log(:delegate, self(), dualpid)
				out = Message.pack(:delegate, self(), self, Message.payload req)
				send dualpid, out

				receive do 
					mailbox when Message.match(mailbox, :mailbox, cref) ->
						{_, newref} = Message.payload req 
						loop(newref, dual)
				end

			req when Message.match(req, :delegate_link, self) ->
 
 				# receive [C]'s pid and ref
				{cpid, cref} = Message.payload req 

				# send [A] to [C] so that [C] turns into a sub-mailbox of [A]
				out = Message.pack(:mailbox, Message.origin(req), self, dual)
				MyLogger.log(:mailbox, self(), cpid)
				send cpid, out 

				# send :delegate to [A] so that [A] can delegate :receive to [C]
				# MyLogger.log(:delegate, self(), dualpid)
				# out = Message.pack(:delegate, self(), self, Message.payload req)
				# send dualpid, out

				receive do 
					mailbox when Message.match(mailbox, :mailbox, cref) ->
						{_, newref} = Message.payload req 
						loop(newref, dual)
				end
			# req when Message.match(req, :mailbox) -> 
				# {_, newref} = Message.payload req 

				# loop(newref, dual)
		end

	end 

	defp init() do 
		receive do 
			{:init, _, {self, pid, other}} ->
				# IO.puts :stderr, "-> :init"
				loop(self, {pid, other})
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
		# MyLogger.log(:send, self(), pid)
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
		# MyLogger.log(:receive, self(), pid)
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
		# MyLogger.log(:close, self(), pid)
		send pid, out 
	end
end 

