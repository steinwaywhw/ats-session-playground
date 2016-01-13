
defmodule Message do 

	def pack(label, pid, ref, payload) do 
		{label, pid, ref, payload}
	end 

	def new_pid(msg, pid) do 
		case msg do 
			{label, _, ref, payload} -> {label, pid, ref, payload}
		end 
	end

	# def new_ref(msg, ref) do 
	# 	case msg do 
	# 		{label, pid, _, payload} -> {label, pid, ref, payload}
	# 	end
	# end

	# def packlite(label, pid, payload) do 
		# {label, pid, payload}
	# end 

	def inspect(msg) do 
		case msg do 
			{label, pid, ref, payload} -> "#{Kernel.inspect label} #{Kernel.inspect payload} as #{Kernel.inspect ref}"
			{label, pid, payload} -> "#{Kernel.inspect label} #{Kernel.inspect payload}"
			_ -> "#{Kernel.inspect msg}"
		end
	end 

	defmacro match(msg, action, ref) do 
		quote do 
			is_tuple(unquote(msg)) 
			and elem(unquote(msg), 0) == unquote(action)
			and elem(unquote(msg), 2) == unquote(ref)
		end
	end

	# defmacro match(msg, action) do 
		# quote do 
			# is_tuple(unquote(msg))
			# and elem(unquote(msg), 0) == unquote(action)
		# end
	# end  

	def origin(msg) do 
		case msg do 
			{_, pid, _, _} -> pid 
			# {_, pid, _} -> pid 
		end
	end 

	def payload(msg) do 
		case msg do 
 			{_, _, _, payload} -> payload 
 			# {_, _, payload} -> payload 
		end
	end 
end


defmodule Session do

	
	@doc """
	Making a publicly shared name from a string.

	Note that nodes should be pre-connected, otherwise names 
	will be conflict.
	"""
	def make_name(name) do 
		name = String.to_atom name
		# IO.puts :stderr, "Making name: #{inspect name}"

		ret = :global.register_name(name, self())
		# IO.puts :stderr, "Registering: #{inspect ret}"

		name
	end

	# def accept(name, f) do 
	# 	IO.puts :stderr, "Listening on #{inspect name} by #{inspect self()}"
	# 	receive do 
	# 		{:request, requester, ^name} ->
	# 			IO.puts :stderr, "Got request from #{inspect requester} on #{inspect name}"
				
	# 			[a, b] = Channel.channel_create()
	# 			IO.puts :stderr, "New channel #{inspect a}, #{inspect b}"
				
	# 			pid = spawn_link fn -> f.(a) end
	# 			IO.puts :stderr, "New thread #{inspect pid} running server code #{inspect f}"
				
	# 			IO.puts :stderr, "Sending channel #{inspect b} to #{inspect requester}"
	# 			send requester, {:accepted, b}
	# 	end 
	# end 

 
	@doc """
	Accept a connection request to a shared name.

	It creates two processes as two ends of a channel. Then it sends
	one end to the requester, and return the other end to the caller. 
	"""
	def accept(name) do 
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
		end 

		# return created channel 
		a
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

		receive do

		 # 	#
			# # send
			# # 
			# msg when Message.match(msg, :send, self) ->
			# 	IO.puts :stderr, "-> #{Message.inspect msg}"

			# 	IO.puts :stderr, "#{inspect pid} <- #{Message.inspect msg}"
			# 	send pid, msg 

			# 	loop(self, pid, other)

			#
			# other's receive
			#
			msg when Message.match(msg, :receive, other) ->
				IO.puts :stderr, "-> #{Message.inspect msg}"

				receive do 
					# self send
					snd when Message.match(snd, :send, self) -> 
						IO.puts :stderr, "-> #{Message.inspect snd}"

						IO.puts :stderr, "#{inspect pid} <- #{Message.inspect snd}"
						send pid, snd

						loop(self, pid, other)

					# self link
					# forward to other end then terminate
					link when Message.match(link, :link, self) ->
						IO.puts :stderr, "-> #{Message.inspect link}"

						IO.puts :stderr, "#{inspect pid} <- #{Message.inspect link}"
						send pid, link
				end 

			#
			# self receive
			# 
			msg when Message.match(msg, :receive, self) ->
				IO.puts :stderr, "-> #{Message.inspect msg}"

				IO.puts :stderr, "#{inspect pid} <- #{Message.inspect msg}"
				send pid, msg

				receive do 
					# other's send
					reply when Message.match(reply, :send, other) ->
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


			# 
			# other's offer
			# 
			msg when Message.match(msg, :offer, other) -> 
				IO.puts :stderr, "-> #{Message.inspect msg}"

				receive do 
					# self choice
					choice when Message.match(choice, :choose, self) -> 
						IO.puts :stderr, "-> #{Message.inspect choice}"

						IO.puts :stderr, "#{inspect pid} <- #{Message.inspect choice}"
						send pid, choice
						
						loop(self, pid, other)

					# self link
					# forward link then terminate
					link when Message.match(link, :link, self) -> 
						IO.puts :stderr, "-> #{Message.inspect link}"

						IO.puts :stderr, "#{inspect pid} <- #{Message.inspect link}"
						send pid, link 
				end 



			#
			# self offer
			# 
			msg when Message.match(msg, :offer, self) ->
				IO.puts :stderr, "-> #{Message.inspect msg}"

				IO.puts :stderr, "#{inspect pid} <- #{Message.inspect msg}"
				send pid, msg

				receive do 
					# other's choice
					reply when Message.match(reply, :choose, other) ->
						IO.puts :stderr, "-> #{Message.inspect reply}"

						IO.puts :stderr, "#{Message.origin msg} <- #{Message.inspect reply}"
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


			# #
			# # choose
			# # 
			# msg when Message.match(msg, :choose, self) ->
			# 	IO.puts :stderr, "-> #{Message.inspect msg}"

			# 	IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
			# 	send pid, msg

			# 	loop(self, pid, other)
 

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
			# msg when Message.match(msg, :link, self) ->
				# IO.puts :stderr, "-> #{Message.inspect msg}"
 
				# {newself, newpid, newother, as} = Message.payload msg

				# out = Message.pack(:meta_reinit, Message.origin(msg), self, {newself, newpid, newother})				
				# # IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
				# # send pid, out 

				# forward_all(newpid, as)
		end
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
		[{pid_a, ref_a, ref_b}, {pid_b, ref_b, ref_a}]
	end

	@doc """
	Send a message through this end of the channel.
	"""
	def channel_send(channel, msg) do
		{pid, ref, other} = channel 
		 
		out = Message.pack(:send, self(), ref, msg)
		IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
		send pid, out
	end

	@doc """
	Receive a message from this end of the channel.

	This is done by sending a `{:receive}` message to this end of the channel.
	"""
	def channel_receive(channel) do 
		{pid, ref, other} = channel

		out = Message.pack(:receive, self(), ref, nil)
		IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
		send pid, out
		
		receive do 
			# send
			msg when Message.match(msg, :send, other) -> 
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
		{pid, ref, other} = channel 

		out = Message.pack(:offer, self(), ref, nil)
		IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
		send pid, out	

		receive do 
			msg when Message.match(msg, :choose, other) ->
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
		{pid_a, ref_a, ref_a_other} = channel_a 
		{pid_b, ref_b, ref_b_other} = channel_b

		to_a = Message.pack(:link, self(), ref_a, {ref_a_other, pid_b_other, ref_b_other, ref_b})
		IO.puts :stderr, "#{inspect pid_a} <- #{Message.inspect to_a}"
		send pid_a, to_a

		to_b = Message.pack(:link, self(), ref_b, {ref_b_other, pid_a_other, ref_a_other, ref_a})
		IO.puts :stderr, "#{inspect pid_b} <- #{Message.inspect to_b}"
		send pid_b, to_b
	end

	defp channel_choose(channel, choice) do 
		{pid, ref, _} = channel 
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
		{pid, ref, _} = channel 
		out = Message.pack(:close, self(), ref, nil)
		IO.puts :stderr, "#{inspect pid} <- #{Message.inspect out}"
		send pid, out 
	end
end 

