
defmodule Message do 

	@doc """
	Packs a message into a pre-defined format.

	A message is of the format `{label, pid, ref, payload}`, where

	* `label` is the message type
	* `pid` is the message origin, which should not be changed in routing
	* `ref` is the message sender's id
	* `payload` is the message payload itself
	"""
	def pack(label, pid, ref, payload) do 
		{label, pid, ref, payload}
	end 

	@doc """
	Inspect a message by converting it to an info string for output.
	"""
	def inspect(msg) do 
		case msg do 
			{label, pid, ref, payload} -> "#{Kernel.inspect label} #{Kernel.inspect payload} as #{Kernel.inspect ref}"
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
			is_tuple(unquote(msg)) the message should have this label
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
			is_tuple(unquote(msg))the message should have this label
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


defmodule Session do

	
	@doc """
	Make a name from a string.
	"""
	def make_name(name) do 
		name = String.to_atom name

		name
	end
 
	@doc """
	Accept a connection request to a shared name.

	It first registers the name globally.

	Then it creates two processes as two ends of a channel. Then it sends
	one end to the requester, and return the other end to the caller. 
	"""
	def accept(name) do 

		:global.register_name(name, self())

		# IO.puts :stderr, "Listening on #{inspect name} by #{inspect self()}"
		receive do 
			{:request, requester, ^name} ->
				# IO.puts :stderr, "Got request from #{inspect requester} on #{inspect name}"
				IO.puts :stderr, "-> #{inspect {:request, requester, name}}"
				
				[a, b] = Channel.channel_create()
				IO.puts :stderr, "New channel #{inspect a}, #{inspect b}"
				
				# pid = spawn_link fn -> f.(a) end
				# IO.puts :stderr, "New thread #{inspect pid} running server code #{inspect f}"
				
				# IO.puts :stderr, "Sending channel #{inspect b} to #{inspect requester}"
				send requester, {:accepted, b}
				IO.puts :stderr, "#{inspect requester} <- #{inspect {:accepted, b}}"

				# return created channel 
				a
		end 

	end  
	

	@doc """
	Requesting a connection to a shared name.

	It will look up a name, sending a request, and waiting to receive 
	one end of the channel.
	"""
	def request(name) do 		
		server = :global.whereis_name name 
		
		IO.puts :stderr, "#{inspect server} <- #{inspect {:request, self(), name}}"
		send server, {:request, self(), name}
		receive do 
			{:accepted, channel} -> 
				IO.puts :stderr, "-> #{inspect {:accepted, channel}}"
				channel
		end 
	end
end

defmodule Channel do 
	
	require Message

	@doc """
	The main channel loop.

	* `self`: this end's ref
	* `pid`: the other end's pid 
	* `other`: the other end's ref
	"""
	defp loop(self, pid, other) do 

		IO.puts :stderr, "loop(#{inspect self}, #{inspect pid}, #{inspect other})"

		receive do

		 	#
			# send
			# 
			msg when Message.match(msg, :send, self) ->
				IO.puts :stderr, "-> #{Message.inspect msg}"

				IO.puts :stderr, "#{inspect pid} <- #{Message.inspect msg}"
				send pid, msg 

				loop(self, pid, other)

			# #
			# # other's receive
			# #
			# msg when Message.match(msg, :receive, other) ->
			# 	IO.puts :stderr, "-> #{Message.inspect msg}"

			# 	receive do 
			# 		# self send
			# 		snd when Message.match(snd, :send, self) -> 
			# 			IO.puts :stderr, "-> #{Message.inspect snd}"

			# 			IO.puts :stderr, "#{inspect pid} <- #{Message.inspect snd}"
			# 			send pid, snd

			# 			loop(self, pid, other)

			# 		# self link
			# 		# forward to other end then terminate
			# 		link when Message.match(link, :link, self) ->
			# 			IO.puts :stderr, "-> #{Message.inspect link}"

			# 			handle_link(link, self, pid, other)
			# 	end 

			#
			# receive
			# 
			msg when Message.match(msg, :receive, self) ->
				IO.puts :stderr, "-> #{Message.inspect msg}"

				receive do 
					# other's send
					snd when Message.match(snd, :send, other) ->
						IO.puts :stderr, "-> #{Message.inspect snd}"

						IO.puts :stderr, "#{inspect Message.origin(msg)} <- #{Message.inspect snd}"
						send Message.origin(msg), snd

						loop(self, pid, other)

					# other's link
					# replay current message 
					link when Message.match(link, :link, other) ->
						IO.puts :stderr, "-> #{Message.inspect link}"

						IO.puts :stderr, "#{inspect self()} <- #{Message.inspect msg}"
						send self(), msg

						{newpid, newother} = Message.payload link 
						loop(self, newpid, newother)
				end 


			#
			# close
			# 
			msg when Message.match(msg, :close, self) ->
				IO.puts :stderr, "-> #{Message.inspect msg}"

				IO.puts :stderr, "#{inspect pid} <- #{Message.inspect msg}"
				send pid, msg

				receive do 
					msg when Message.match(msg, :close, other) ->
						IO.puts :stderr, "-> #{Message.inspect msg}"
						nil
				end 


			# # 
			# # other's offer
			# # 
			# msg when Message.match(msg, :offer, other) -> 
			# 	IO.puts :stderr, "-> #{Message.inspect msg}"

			# 	receive do 
			# 		# self choice
			# 		choice when Message.match(choice, :choose, self) -> 
			# 			IO.puts :stderr, "-> #{Message.inspect choice}"

			# 			IO.puts :stderr, "#{inspect pid} <- #{Message.inspect choice}"
			# 			send pid, choice
						
			# 			loop(self, pid, other)

			# 		# self link
			# 		# forward link then terminate
			# 		link when Message.match(link, :link, self) -> 
			# 			IO.puts :stderr, "-> #{Message.inspect link}"

			# 			handle_link(link, self, pid, other)
			# 	end 



			#
			# offer
			# 
			msg when Message.match(msg, :offer, self) ->
				IO.puts :stderr, "-> #{Message.inspect msg}"

				# IO.puts :stderr, "#{inspect pid} <- #{Message.inspect msg}"
				# send pid, msg

				receive do 
					# other's choice
					reply when Message.match(reply, :choose, other) ->
						IO.puts :stderr, "-> #{Message.inspect reply}"

						IO.puts :stderr, "#{inspect Message.origin(msg)} <- #{Message.inspect reply}"
						send Message.origin(msg), reply

						loop(self, pid, other)

					# other's link 
					# replay current message
					link when Message.match(link, :link, other) -> 
						IO.puts :stderr, "-> #{Message.inspect link}"

						IO.puts :stderr, "#{inspect self()} <- #{Message.inspect msg}"
						send self(), msg 

						{newpid, newother} = Message.payload link 
						loop(self, newpid, newother) 			
				end 


			#
			# choose
			# 
			msg when Message.match(msg, :choose, self) ->
				IO.puts :stderr, "-> #{Message.inspect msg}"

				IO.puts :stderr, "#{inspect pid} <- #{Message.inspect msg}"
				send pid, msg

				loop(self, pid, other)
 

			#
			# meta_reinit
			# 
			# msg when Message.match(msg, :meta_reinit, self) ->
				# IO.puts :stderr, "-> #{Message.inspect msg}"
# 
				# {newself, newpid, newother} = Message.payload msg 
				# loop(newself, newpid, newother)

			#			
			# link
			# 
			msg when Message.match(msg, :link, self) ->
				IO.puts :stderr, "-> #{Message.inspect msg}"
 
				{targetpid, targetref} = Message.payload msg 
				out = Message.pack(:link, Message.origin(msg), self, {pid, other})

				IO.puts :stderr, "#{inspect targetpid} <- #{Message.inspect out}"
				send targetpid, out 

				receive do 
					reply when Message.match(reply, :link, targetref) -> 
						IO.puts :stderr, "-> #{Message.inspect reply}"

						out = Message.pack(:link, Message.origin(reply), self, Message.payload(reply))

						IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
						send pid, out

						# there should be only one blocking messages to be forwarded
						# TODO: prove it
						receive do 
							any -> 
								IO.puts :stderr, "-> #{Message.inspect any}"
								
								{targetpid, _} = Message.payload reply
								IO.puts :stderr, "#{inspect targetpid} <- #{Message.inspect any}"
								send targetpid, any
						end
				end
		end

		IO.puts :stderr, "#{inspect self()} CLOSED"
	end 


	# defp forward_all(to, as) do 
	# 	# {_, len} = :erlang.process_info(self(), :message_queue_len)
	# 	# if len > 0 do 
	# 		receive do 
	# 			{label, pid, ref, payload} -> 
	# 				IO.puts :stderr, "FORWARDING -> #{inspect label} #{inspect payload}"

	# 				out = Message.pack(label, pid, as, payload)
	# 				send to, out
	# 				IO.puts :stderr, "FORWARDING #{inspect to} <- #{Message.inspect out} as #{inspect as}"
	# 		end 
	# 		forward_all(to, as)
	# 	# end 
	# end



	# defp handle_link(msg, self, pid, other) do 
	# 	{targetpid, targetref} = Message.payload msg 
	# 	out = Message.pack(:link, Message.origin(msg), self, {pid, other})

	# 	IO.puts :stderr, "#{inspect targetpid} <- #{Message.inspect out}"
	# 	send targetpid, out 

	# 	receive do 
	# 		reply when Message.match(reply, :link, targetref) -> 
	# 			IO.puts :stderr, "-> #{Message.inspect reply}"

	# 			out = Message.pack(:link, Message.origin(reply), self, Message.payload(reply))

	# 			IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
	# 			send pid, out
	# 	end
	# end

	defp init() do 
		receive do 
			{:init, _, {self, pid, other}} ->
				IO.puts :stderr, "-> :init"
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

		IO.puts :stderr, "#{inspect pid_a} <- #{inspect to_a}"
		IO.puts :stderr, "#{inspect pid_b} <- #{inspect to_b}"
		
		send pid_a, to_a
		send pid_b, to_b

		# return two ends and refs of the channel
		[{pid_a, ref_a}, {pid_b, ref_b}]
	end

	@doc """
	Send a message through this end of the channel.
	"""
	def channel_send(channel, msg) do
		{pid, ref} = channel 
		 
		out = Message.pack(:send, self(), ref, msg)
		IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
		send pid, out
	end

	@doc """
	Receive a message from this end of the channel.

	This is done by sending a `{:receive}` message to this end of the channel.
	"""
	def channel_receive(channel) do 
		{pid, ref} = channel

		out = Message.pack(:receive, self(), ref, nil)
		IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
		send pid, out
		
		receive do 
			# send
			msg when Message.match(msg, :send) -> 
				IO.puts :stderr, "-> #{Message.inspect msg}"
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
	def channel_offer(channel, fn_a, fn_b) do 
		{pid, ref} = channel 

		out = Message.pack(:offer, self(), ref, nil)
		IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
		send pid, out	

		receive do 
			msg when Message.match(msg, :choose) ->
				IO.puts :stderr, "-> #{Message.inspect msg}"

				case Message.payload(msg) do 
					0 -> fn_a.(channel)
					1 -> fn_b.(channel)
				end 
		end 
	end


	@doc """
	Link two channels dual ends, as bidirectional forwarding.
	"""
	def channel_link(channel_a, channel_b) do 
		{pid_a, ref_a} = channel_a 
		{pid_b, ref_b} = channel_b

		to_a = Message.pack(:link, self(), ref_a, channel_b)
		IO.puts :stderr, "#{inspect pid_a} <- #{Message.inspect to_a}"
		send pid_a, to_a

		to_b = Message.pack(:link, self(), ref_b, channel_a)
		IO.puts :stderr, "#{inspect pid_b} <- #{Message.inspect to_b}"
		send pid_b, to_b
	end

	defp channel_choose(channel, choice) do 
		{pid, ref} = channel 
		out = Message.pack(:choose, self(), ref, choice)
		IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
		send pid, out
	end 

	def channel_choose_fst(channel) do 
		channel_choose(channel, 0)
	end 

	def channel_choose_snd(channel) do 
		channel_choose(channel, 1)
	end

	def channel_close(channel) do 
		{pid, ref} = channel 
		out = Message.pack(:close, self(), ref, nil)
		IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
		send pid, out 
	end
end 

