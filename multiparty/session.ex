
defmodule SessionData do 
	defstruct name: nil, self: nil, parts: nil 
end

defmodule PartData do 
	defstruct part: nil, ref: nil, pid: nil
end 

defmodule Msg do 
	defstruct label: nil, from: nil, ref: nil, payload: nil
end


defmodule Utils do 
	require Logger

	def set2erl(set, f) do 
		ret = f.(set, [], fn x, s -> [x] ++ s end)
		Logger.debug "#{inspect ret}"

		ret
	end 

	def getref(%SessionData{parts: parts}, part) do
		%PartData{ref: ref} = parts |> Enum.find(fn %PartData{part: p} -> part == p end)

		ref 
	end

	def getref(%SessionData{self: self, parts: parts}) do 
		%PartData{ref: ref} = parts |> Enum.find(fn %PartData{part: part} -> part == hd(self) end)

		ref 
	end 

	def getpid(%SessionData{parts: parts}, part) do 
		%PartData{pid: pid} = parts |> Enum.find(fn %PartData{part: p} -> part == p end)

		pid 
	end 

	def getpid(%SessionData{self: self, parts: parts}) do 
		%PartData{pid: pid} = parts |> Enum.find(fn %PartData{part: part} -> part == hd(self) end)

		pid 
 	end

 	def tostring(anything) do 
 		Kernel.inspect(anything, pretty: true)
 	end 

 	def debug(string) do 
 		Logger.debug string 
 	end 

 	def info(string) do 
 		Logger.info string 
 	end 

	# def isok(value) do 
	# 	case value do 
	# 		:ok -> true 
	# 		_ -> false 
	# 	end 
	# end 

	def isno(value) do 
		case value do 
			:no -> true 
			_ -> false 
		end 
	end  
end 


defmodule NameServer do 
	require Logger

	def register(session, part, partdata) do 
		:gproc.reg({:n, :g, {session, part}}, partdata)
	end

	def await(session, parts) do 

		table = Enum.map parts, fn part -> 
			Logger.debug "waiting for #{part}"

			key = {:n, :g, {session, part}}
			query = :gproc.where key

			if is_pid(query) do 
				query = :gproc.lookup_value key 
			else 	
				{_, query} = :gproc.await key
			end 
			Logger.debug "got #{inspect query}"

			query
		end
		# table = Enum.map(table, fn {_, {partdata, gp}} -> {partdata, gp} end)
		table
	end

	def unregister(session, parts) do 
		for part <- parts, do: :gproc.unreg({:n, :g, {session, part}})
	end

end

defmodule Endpoint do 

	require NameServer
	require Logger	

	def create(name, self, parts, gp) do 
		parent = self()
		pid = spawn_link fn -> init(parent, name, self, parts, gp) end

		ret = receive do 
			%Msg{label: :init, payload: :no} -> :no 
			%Msg{label: :init, payload: session} -> session 
		end 

		Logger.debug "ret = #{inspect ret}"
		ret 
	end 

	defp init(parent, name, self, parts, gp) do


		# register pid as [{name, part} => partdata]
		# all parts that belong to self, will have same ref
		ret = try do 
			pid = self()
			ref = make_ref()

			Enum.each self, fn s -> 
				NameServer.register(name, s, {%PartData{part: s, ref: ref, pid: pid}, gp})
			end
		rescue 
			_ -> :no
		end

		Logger.debug "ret = #{inspect ret}"

		# if failed, notify create()
		if ret == :no do 
			send parent, %Msg{label: :init, payload: ret}

		# if succeeded, wait for other parts
		else 
			parts = NameServer.await(name, parts)
			Logger.debug "parts = #{inspect parts, pretty: true}"

			# check all other runtime type data
			ret = Enum.all?(parts, fn {_, othergp} -> othergp == gp end)

			Logger.debug "ret = #{inspect ret}"

			# if all correct, notify create(), run loop
			if ret == true do 
				parts = for {partdata, _} <- parts, do: partdata
				session = %SessionData{name: name, self: self, parts: parts}
				send parent, %Msg{label: :init, payload: session}

				Logger.debug "session = #{inspect session, pretty: true}"

				NameServer.unregister(name, self)

				loop session


			# else, notify create()
			else 
				send parent, %Msg{label: :init, payload: :no}
			end
		end
	end 

	def send(%SessionData{self: self, parts: parts} = session, to, payload) do 
		# if to >= 0 do 
		send Utils.getpid(session), %Msg{label: :send, from: self(), ref: Utils.getref(session), payload: {to, payload}} 
		# else
			# send pid, %Msg{label: :broadcast, from: self(), ref: ref, payload: payload}
		# end
	end 

	def recv(%SessionData{self: self, parts: parts} = session, from) do 
		send Utils.getpid(session), %Msg{label: :recv, from: self(), ref: Utils.getref(session), payload: from}

		pid = Utils.getpid(session)
		receive do
			%Msg{label: :recv, payload: payload, from: ^pid} -> payload 
		end
	end 

	def choose(%SessionData{self: self, parts: parts} = session, choice) do 
		send Utils.getpid(session), %Msg{label: :choose, from: self(), ref: Utils.getref(session), payload: choice}

		choice
	end 

	def offer(%SessionData{self: self, parts: parts} = session, from) do 
		choices = Enum.map self, fn part -> 
			send Utils.getpid(session), %Msg{label: :offer, from: self(), ref: Utils.getref(session), payload: from} 

			pid = Utils.getpid(session)
			receive do 
				%Msg{label: :offer, payload: choice, from: ^pid} -> choice 
			end
		end

		hd choices
	end 

	def close(%SessionData{self: self, parts: parts} = session) do 
		ref = Utils.getref(session)
		pid = Utils.getpid(session)
		send pid, %Msg{label: :close, from: self(), ref: ref}

		:ok
	end 

	def link(%SessionData{self: x} = sx, %SessionData{self: y} = sy) do 

		Logger.debug "Linking #{inspect x} and #{inspect y}"
		Logger.debug "#{inspect sx, pretty: true}"
		Logger.debug "#{inspect sy, pretty: true}"

		parts = for %PartData{part: part} <- sx.parts, do: part 

		newself = (x ++ y) -- parts
		Logger.debug "New Self #{inspect newself}"

		wait = fn -> receive do 
				session -> loop session 
			end 
		end

		newpid = spawn_link fn -> wait.() end 
		newref = make_ref()

		Logger.debug "New Pid #{inspect newpid}"
		Logger.debug "New Ref #{inspect newref}"


		newparts = Enum.map parts, fn part -> 
			cond do 
				Enum.member? newself, part -> 
					%PartData{part: part, pid: newpid, ref: newref}
				Enum.member? parts -- x, part -> 
					%PartData{part: part, pid: Utils.getpid(sx, part), ref: Utils.getref(sx, part)}
				Enum.member? parts -- y, part -> 
					%PartData{part: part, pid: Utils.getpid(sy, part), ref: Utils.getref(sy, part)}
			end
		end



		newss = %SessionData{sx | parts: newparts, self: newself}
		send newpid, newss

		Logger.debug "#{inspect newss, pretty: true}"

		# send Utils.getpid(sx), %Msg{label: :link, ref: Utils.getref(sx), payload: newss}
		# send Utils.getpid(sy), %Msg{label: :link, ref: Utils.getref(sy), payload: newss}

		(for %PartData{pid: pid, part: part} <- sx.parts, do: pid) 
		|> Enum.sort 
		|> Enum.dedup
		|> Enum.each(fn pid -> send pid, %Msg{label: :link, ref: Utils.getref(sx), payload: newss} end)

		(for %PartData{pid: pid, part: part} <- sy.parts, do: pid) 
		|> Enum.sort 
		|> Enum.dedup
		|> Enum.each(fn pid -> send pid, %Msg{label: :link, ref: Utils.getref(sy), payload: newss} end)

		newss
	end 


	defp loop(session) do 
		parts = session.parts
		self = session.self
		# self = parties[self]
		ref = Utils.getref(session)

		# Logger.info "#{inspect Process.info(self(), :messages), pretty: true}"

		# # selfref = self.ref
		receive do 
			%Msg{label: :send, ref: ^ref, payload: {to, payload}} = req -> 
				send Utils.getpid(session, to), req
				loop session 

			%Msg{label: :recv, ref: ^ref, payload: from} = req -> 

				target = Utils.getref(session, from)
				receive do 
					%Msg{label: :send, ref: ^target, payload: {_, payload}} = msg -> 
						send req.from, %Msg{msg | label: :recv, from: self(), payload: payload}
						loop session 
					%Msg{label: :link, ref: _, payload: newsession} -> 
						send self(), req
						loop %SessionData{newsession | self: self}
				end 

		# 	%Msg{label: :broadcast, ref: ^ref, payload: payload} = req -> 
		# 		for {party, endpoint} <- parties, party != session.self, do: send endpoint.pid, %Msg{req | label: :msg}
		# 		loop session 

			%Msg{label: :offer, ref: ^ref, payload: from} = req -> 

				target = Utils.getref(session, from)
				receive do 
					%Msg{label: :choose, ref: ^target, payload: choice} = msg -> 
						send req.from, %{msg | label: :offer, from: self()}
						loop session 
					%Msg{label: :link, ref: _, payload: newsession} -> 
						send self(), req 
						loop %SessionData{newsession | self: self}
				end 

			%Msg{label: :choose, ref: ^ref, payload: choice} = req -> 
				for %PartData{pid: pid, part: part} <- parts, Enum.member?(self, part) == false, do: send pid, req
				loop session 
		 		
			%Msg{label: :link, ref: ^ref, payload: newsession} = req -> 
				send self(), %Msg{label: :forward, ref: ref, payload: newsession}
				loop session 

			%Msg{label: :forward, ref: ^ref, payload: newsession} = forward -> 
				{_, len} = Process.info(self(), :message_queue_len)
				# Logger.info "In #{inspect self()} Forwarding #{inspect Process.info(self(), :messages), pretty: true}"

				if len > 0 do 
					receive do 
						%Msg{label: :send, ref: _, payload: {to, _}} = req ->
							send Utils.getpid(newsession, to), req
							send self(), forward
							loop session 

						%Msg{label: :choose, ref: _, payload: _} = req -> 
							for to <- self, do: send Utils.getpid(newsession, to), req
							send self(), forward
							loop session 
					end
				else 
					Logger.info "TERM"
					:ok
				end


			%Msg{label: :close, ref: ^ref} = req -> 
				# for {party, endpoint} <- parties, party != session.self, do: send endpoint.pid, req
				# Enum.each(parties, fn({party, endpoint}) -> 
					# if party != session.self do
						# receive do 
							# %Msg{label: :close, ref: remote_ref} when ref != remote_ref -> :ok 
						# end
					# end 
				# end)
				# 
				#  TODO need to move this to the beginning of session
				Logger.info "CLOSED"
				:ok
		end
	end
end


defmodule Session do 
	require Logger 

	def init(name, self, parts, gp) do 		
		session = Endpoint.create(name, self, parts, gp)
		Logger.debug "#{inspect session}"
		session
	end 



	# def request(name, gp, self, arity) do 	

	# 	# register {name, party}
	# 	ret = :global.register_name({name, self}, self())
	# 	if ret == :no, do: raise "Registering #{name} for #{self} => #{self()} failed."

	# 	# find all other parties [{name, party}] => [{party, parent_pid}]
	# 	pids = for party <- 0 .. arity - 1, party != self, do: {party, :global.whereis_name {name, party}}
	# 	if Enum.any?(pids, fn({_, parent_pid}) -> parent_pid == :undefined end), do: raise "Not all parties are online."

	# 	# function for requesting endpoint
	# 	f = fn({party, parent_pid}) -> 
	# 		# send parent_pid, {:request, self(), {name, gp}}
	# 		send parent_pid, %Msg{label: :request, from: self(), payload: {name, gp}}
	# 		receive do
	# 			%Msg{label: :accept, payload: %EndpointData{self: ^party} = endpoint} -> {endpoint.self, endpoint}
	# 			%Msg{label: :reject, payload: {^party, reason}} -> raise "Request rejected: #{party} - #{reason}"
	# 			# {:accept, %EndpointData{self: ^party} = endpoint} -> {endpoint.self, endpoint}
	# 			# {:reject, {^party, reason}} -> raise "Request rejected: #{party} - #{reason}"
	# 		end
	# 	end

	# 	# [{party, parent_pid}] |> [{party, endpoint}] |> %{party, endpoint} ++ %{self, endpoint}
	# 	parties = Enum.map(pids, f) |> Map.new |> Map.put(self, Endpoint.create(self))

	# 	# init all parties
	# 	session = %SessionData{self: self, parties: parties}
	# 	init session

	# 	:global.unregister_name({name, self})

	# 	# return endpoint
	# 	session.parties[session.self]
	# end 


	# def accept(name, check, self, task) do 

	# 	# register {name, party}
	# 	ret = :global.register_name({name, self}, self())
	# 	if ret == :no, do: raise "Registering #{name} for #{self} => #{inspect self()} failed."

	# 	receive do 
	# 		%Msg{label: :request, payload: {^name, gp}} = msg ->
	# 		# {:request, req, {^name, gp}} -> 

	# 			# check protocol
	# 			if check.(gp) do
	# 				endpoint = Endpoint.create self
	# 				spawn fn -> task.(endpoint) end
	# 				# send req, {:accept, endpoint}
	# 				send msg.from, %Msg{label: :accept, payload: endpoint}
	# 			else
	# 				# send req, {:reject, {self, "Protocol mismatch."}}
	# 				send msg.from, %Msg{label: :reject, payload: {self, "Protocol mismatch."}}
	# 				accept(name, check, self, task)
	# 			end
	# 	end

	# 	:global.unregister_name({name, self})
	# 	:ok
	# end 

end 