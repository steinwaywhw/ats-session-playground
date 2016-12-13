
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

			query
		end
		table
	end

	def unregister(session, parts) do 
		for part <- parts, do: if is_pid(:gproc.where {:n, :g, {session, part}}), do: :gproc.unreg({:n, :g, {session, part}})
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

		# if failed, notify create()
		if ret == :no do 
			send parent, %Msg{label: :init, payload: ret}

		# if succeeded, wait for other parts
		else 
			parts = NameServer.await(name, parts)

			# check all other runtime type data
			ret = Enum.all?(parts, fn {_, othergp} -> othergp == gp end)

			# if all correct, notify create(), run loop
			if ret == true do 
				parts = for {partdata, _} <- parts, do: partdata
				session = %SessionData{name: name, self: self, parts: parts}
				send parent, %Msg{label: :init, payload: session}
				send self(), %Msg{label: :sync, ref: Utils.getref(session)}
				loop session

			# else, notify create()
			else 
				send parent, %Msg{label: :init, payload: :no}
			end
		end
	end 

	def send(%SessionData{self: self, parts: parts} = session, to, payload) do 
		send Utils.getpid(session), %Msg{label: :send, from: self(), ref: Utils.getref(session), payload: {to, payload}} 
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

		parts = for %PartData{part: part} <- sx.parts, do: part 

		newself = (x ++ y) -- parts

		wait = fn -> receive do 
				session -> loop session 
			end 
		end

		newpid = spawn_link fn -> wait.() end 
		newref = make_ref()

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
		ref = Utils.getref(session)

		receive do 
			%Msg{label: :sync, ref: ^ref} = req ->
				(for %PartData{pid: pid, part: part, ref: ref} <- parts, do: {pid, ref}) 
				|> Enum.sort 
				|> Enum.dedup
				|> Enum.each(fn {pid, ref} -> 
					send pid, req
					receive do 
						%Msg{label: :sync, ref: ^ref} -> :ok
					end
				end)

				# safely unregister my own names after sync
				NameServer.unregister(session.name, self)
				loop session 

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
				Logger.info "CLOSED"
				:ok
		end
	end
end


defmodule Session do 
	require Logger 

	def init(name, self, parts, gp) do 		
		session = Endpoint.create(name, self, parts, gp)
		session
	end 

end 