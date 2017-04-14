


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
				MyLogger.log(:send, self(), dualpid)
				send dualpid, req 
				delegate_loop(self, dual, sub)
		
			req when Message.match(req, :receive, self) ->

				{_, messages} = :erlang.process_info(self(), :messages)
				has_it = List.foldl(messages, false, fn(msg, acc) -> acc or Message.match(msg, :send, dualref) end)

				if has_it do 
					receive do 
						snd when Message.match(snd, :send, dualref) ->
							MyLogger.log(:received, self(), Message.origin(req))
							send Message.origin(req), snd
							delegate_loop(self, dual, sub)
					end
				else 
					MyLogger.log(:delegate_receive, self(), subpid)
					out = Message.pack(:receive, Message.origin(req), subref, Message.payload(req))
					send subpid, out
					delegate_loop(self, dual, sub)
				end
				

				

			req when Message.match(req, :close, self) ->
				MyLogger.log(:delegate_close, self(), subpid)
				out = Message.pack(:close, Message.origin(req), subref, Message.payload(req))
				send subpid, out

				:closed 

			# :delegate is telling an endpoint to enter the 
			# delegate mode, by adding a third argument, sub-mailbox, to the loop
			req when Message.match(req, :delegate, self) -> 
				# propogate :delegate to all subs
				MyLogger.log(:delegate_delegate, self(), subpid)
				out = Message.pack(:delegate, Message.origin(req), subref, Message.payload(req))
				send subpid, out

				delegate_loop(self, dual, sub)

			
			# Delegate to the last sub
			# 
			# Say we are trying to link [B] and [C], and this is in [B] now.
			# The last sub [a] will send out 
			# 
			# - :delegate(signed as Aref) to [A]
			# 
			# And [B] merely delegates the :link to [a]. 
			# 
			#          <=>
			# [A]<=>[B]   [C]<=>[D]
			#  |     |     |     |
			# [b]   [a]   [d]   [c]
			req when Message.match(req, :link, self) ->

				MyLogger.log(:delegate_link, self(), subpid)
				out = Message.pack(:link, Message.origin(req), subref, Message.payload(req)) 
				send subpid, out

				delegate_loop(self, dual, sub)
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
				MyLogger.log(:send, self(), dualpid)
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
						MyLogger.log(:received, self(), Message.origin(req))
						send Message.origin(req), snd
						loop(self, dual)

					# found :delegate
					# Case 2
					delegate when Message.match(delegate, :delegate, self) ->

						# replay the :receive request
						MyLogger.log(:replay_receive, self(), self())
						send self(), req

						# switch to delegate mode
						delegate_loop(self, dual, Message.payload delegate)
				end 


			req when Message.match(req, :delegate, self) ->
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
			# - :link(signed as aref), with info about [C]
			# 
			# and [a] will send,
			# 
			# - and :delegate(signed as Aref) about info of [C] to [A]
			# 
			#          <=>
			# [A]<=>[B]   [C]<=>[D]
			#  |     |     |     |
			# [b]   [a]   [d]   [c]
			req when Message.match(req, :link, self) ->
 
				# send :delegate to [A] so that [A] can delegate :receive to [C]
				MyLogger.log(:delegate, self(), dualpid)
				out = Message.pack(:delegate, self(), dualref, Message.payload req)
				send dualpid, out

				loop(self, dual)

		end

	end 

	defp init() do 
		receive do 
			{:init, _, {self, pid, other}} ->
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
		MyLogger.log(:receive, self(), pid)
		send pid, out
		
		receive do 
			msg when Message.match(msg, :send) -> 
				Message.payload msg
		end 
	end

	@doc """
	Link two channels dual ends, as bidirectional forwarding.
	"""
	def channel_link(channel_a, channel_b) do 
		{pid_a, ref_a} = channel_a 
		{pid_b, ref_b} = channel_b

		to_a = Message.pack(:link, self(), ref_a, channel_b)
		MyLogger.log(:link, self(), pid_a)
		send pid_a, to_a

		to_b = Message.pack(:link, self(), ref_b, channel_a)
		MyLogger.log(:link, self(), pid_b)
		send pid_b, to_b
	end

	def channel_close(channel) do 
		{pid, ref} = channel 
		out = Message.pack(:close, self(), ref, nil)
		MyLogger.log(:close, self(), pid)
		send pid, out 
	end
end 

