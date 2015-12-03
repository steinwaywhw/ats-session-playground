
defmodule Session do
	def make_name(name) do 
		name = String.to_atom name
		IO.puts "Making name: #{inspect name}"

		ret = :global.register_name(name, self())
		IO.puts "Registering: #{inspect ret}"

		name
	end

	def accept(name, f) do 
		IO.puts "Listening on #{inspect name} by #{inspect self()}"
		receive do 
			{:request, requester, ^name} ->
				IO.puts "Got request from #{inspect requester} on #{inspect name}"
				
				[a, b] = Channel.channel_create()
				IO.puts "New channel #{inspect a}, #{inspect b}"
				
				pid = spawn_link fn -> f.(a) end
				IO.puts "New thread #{inspect pid} running server code #{inspect f}"
				
				IO.puts "Sending channel #{inspect b} to #{inspect requester}"
				send requester, {:accepted, b}
		end 
	end 

	def request(name) do 
		IO.puts "Requesting #{inspect name} from #{inspect self()}"
		
		server = :global.whereis_name name 
		IO.puts "Server is at #{inspect server}, sending request"
		
		send server, {:request, self(), name}
		receive do 
			{:accepted, channel} -> 
				IO.puts "Accepted, channel: #{inspect channel}"
				channel
		end 
	end
end

defmodule Channel do 
	

	defp loop(pid, a, b) do 
		receive do 
			{:send, requester, ^a, msg} -> 
				send pid, {:send, requester, a, msg}
				loop(pid, a, b)

			{:receive, requester, ^a} -> 
				IO.puts "Got receving request from #{inspect requester} as #{inspect a}"
				receive do 
					{:send, sender, ^b, msg} ->
						send requester, {:send, sender, msg}
				end 
				loop(pid, a, b)

			{:close, requester, ^a} ->
				send pid, {:close, requester, a}
				receive do 
					{:close, _, ^b} -> nil
				end 

			{:offer, requester, ^a} ->
				send pid, {:offer, requester, a}
				receive do 
					{:choose, sender, ^b, choice} ->
						send requester, {:choose, sender, choice}
				end 
				loop(pid, a, b)

			{:choose, requester, ^a, choice} -> 
				send pid, {:choose, requester, a, choice}
				loop(pid, a, b)
		end
	end 

	defp init() do 
		receive do 
			{:init, pid, a, b} -> loop(pid, a, b)
		end 
	end 

	def channel_create() do 
		ref_a = make_ref()
		ref_b = make_ref()
		pid_a = spawn_link fn -> init() end
		pid_b = spawn_link fn -> init() end

		send pid_a, {:init, pid_b, ref_a, ref_b}
		send pid_b, {:init, pid_a, ref_b, ref_a}

		# return two ends of the channel
		[{pid_a, ref_a}, {pid_b, ref_b}]
	end

	def channel_send(channel, msg) do
		{pid, ref} = channel 
		IO.puts "Sending #{inspect msg} to channel #{inspect pid} as #{inspect ref}"
		send pid, {:send, self(), ref, msg}
	end

	def channel_receive(channel) do 
		{pid, ref} = channel
		IO.puts "Receiving from channel #{inspect pid} as #{inspect ref}"
		send pid, {:receive, self(), ref}
		receive do 
			{:send, _, msg} -> 
				IO.puts "Received #{inspect msg}"
				msg
		end 
	end

	def channel_offer(channel, fn_a, fn_b) do 
		{pid, ref} = channel 
		IO.puts "Offering choices to channel #{inspect pid} as #{inspect ref}"
		send pid, {:offer, self(), ref}
		receive do 
			{:choose, _, choice} -> 
				case choice do 
					0 -> fn_a.(channel)
					1 -> fn_b.(channel)
				end 
		end 
	end

	defp channel_choose(channel, choice) do 
		{pid, ref} = channel 
		IO.puts "Choosing #{inspect choice} to channel #{inspect pid} as #{inspect ref}"
		send pid, {:choose, self(), ref, choice}
	end 

	def channel_choose_fst(channel) do 
		channel_choose(channel, 0)
	end 

	def channel_choose_snd(channel) do 
		channel_choose(channel, 1)
	end

	def channel_close(channel) do 
		{pid, ref} = channel 
		send pid, {:close, self(), ref}
	end
end 

