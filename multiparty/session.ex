



defmodule SessionData do 
	defstruct self: nil, parties: %{}
end

defmodule EndpointData do 
	defstruct self: nil, pid: nil, ref: nil
end

defmodule Msg do 
	defstruct label: nil, from: nil, ref: nil, payload: nil
end


defmodule Endpoint do 

	def create(self) do 
		%EndpointData{self: self, ref: make_ref(), pid: spawn fn -> init(self) end}
	end 

	def send(payload, to, %EndpointData{self: self, pid: pid, ref: ref}) do 
		if to >= 0 do 
			send pid, %Msg{label: :send, from: self(), ref: ref, payload: {to, payload}} 
		else
			send pid, %Msg{label: :broadcast, from: self(), ref: ref, payload: payload}
		end
	end 

	def recv(from, %EndpointData{self: self, pid: pid, ref: ref}) do 
		send pid, %Msg{label: :recv, from: self(), ref: ref, payload: from}

		receive do
			%Msg{label: :recv, payload: payload} -> payload 
		end
	end 

	def choose(choice, %EndpointData{self: self, pid: pid, ref: ref}) do
		send pid, %Msg{label: :choose, from: self(), ref: ref, payload: choice}

		choice
	end 

	def offer(from, %EndpointData{self: self, pid: pid, ref: ref}) do 
		send pid, %Msg{label: :offer, from: self(), ref: ref, payload: from}

		receive do 
			%Msg{label: :offer, payload: choice} -> choice 
		end
	end 

	def close(%EndpointData{self: self, pid: pid, ref: ref}) do 
		send pid, %Msg{label: :close, from: self(), ref: ref}

		:ok
	end 

	def link() do 
	end 


	def init(self) do 
		receive do 
			%Msg{label: :init, payload: %SessionData{self: ^self} = session} -> loop session
			# {:init, %SessionData{self: ^self} = session} -> loop session
		end
	end 


	defp loop(session) do 
		parties = session.parties
		self = session.self
		self = parties[self]
		ref = self.ref

		# selfref = self.ref
		receive do 
			%Msg{label: :send, ref: ^ref, payload: {to, payload}} = req -> 
				send parties[to].pid, %Msg{req | label: :msg, payload: payload}
				loop session 

			%Msg{label: :recv, ref: ^ref, payload: from} = req -> 

				target = parties[from].ref
				receive do 
					%Msg{label: :msg, ref: ^target, payload: payload} = msg -> 
						send req.from, %Msg{msg | label: :recv}
				end 
				loop session 

			%Msg{label: :broadcast, ref: ^ref, payload: payload} = req -> 
				for {party, endpoint} <- parties, party != session.self, do: send endpoint.pid, %Msg{req | label: :msg}
				loop session 

			%Msg{label: :offer, ref: ^ref, payload: from} = req -> 

				target = parties[from].ref 
				receive do 
					%Msg{label: :choose, ref: ^target, payload: choice} = msg -> 
						send req.from, %{msg | label: :offer}
				end 
				loop session 

			%Msg{label: :choose, ref: ^ref, payload: choice} = req -> 
				for {party, endpoint} <- parties, party != session.self, do: send endpoint.pid, req
				loop session 

			%Msg{label: :close, ref: ^ref} = req -> 
				for {party, endpoint} <- parties, party != session.self, do: send endpoint.pid, req
				Enum.each(parties, fn({party, endpoint}) -> 
					if party != session.self do
						receive do 
							%Msg{label: :close, ref: remote_ref} when ref != remote_ref -> :ok 
						end
					end 
				end)

				:ok
		end
	end
end


defmodule Session do 

	# defstruct self: nil, parties: %{}

	def make_name(name) do 
		String.to_atom name
	end 

	defp init(session) do 
		f = fn({party, %EndpointData{self: self, pid: pid, ref: ref}}) -> 
			# send pid, {:init, %SessionData{session | self: party}}
			send pid, %Msg{label: :init, payload: %SessionData{session | self: party}}
		end

		Enum.each(session.parties, f)

		:ok
	end


	def request(name, gp, self, arity) do 	

		# register {name, party}
		ret = :global.register_name({name, self}, self())
		if ret == :no, do: raise "Registering #{name} for #{self} => #{self()} failed."

		# find all other parties [{name, party}] => [{party, parent_pid}]
		pids = for party <- 0 .. arity - 1, party != self, do: {party, :global.whereis_name {name, party}}
		if Enum.any?(pids, fn({_, parent_pid}) -> parent_pid == :undefined end), do: raise "Not all parties are online."

		# function for requesting endpoint
		f = fn({party, parent_pid}) -> 
			# send parent_pid, {:request, self(), {name, gp}}
			send parent_pid, %Msg{label: :request, from: self(), payload: {name, gp}}
			receive do
				%Msg{label: :accept, payload: %EndpointData{self: ^party} = endpoint} -> {endpoint.self, endpoint}
				%Msg{label: :reject, payload: {^party, reason}} -> raise "Request rejected: #{party} - #{reason}"
				# {:accept, %EndpointData{self: ^party} = endpoint} -> {endpoint.self, endpoint}
				# {:reject, {^party, reason}} -> raise "Request rejected: #{party} - #{reason}"
			end
		end

		# [{party, parent_pid}] |> [{party, endpoint}] |> %{party, endpoint} ++ %{self, endpoint}
		parties = Enum.map(pids, f) |> Map.new |> Map.put(self, Endpoint.create(self))

		# init all parties
		session = %SessionData{self: self, parties: parties}
		init session

		:global.unregister_name({name, self})

		# return endpoint
		session.parties[session.self]
	end 


	def accept(name, check, self, task) do 

		# register {name, party}
		ret = :global.register_name({name, self}, self())
		if ret == :no, do: raise "Registering #{name} for #{self} => #{inspect self()} failed."

		receive do 
			%Msg{label: :request, payload: {^name, gp}} = msg ->
			# {:request, req, {^name, gp}} -> 

				# check protocol
				if check.(gp) do
					endpoint = Endpoint.create self
					spawn fn -> task.(endpoint) end
					# send req, {:accept, endpoint}
					send msg.from, %Msg{label: :accept, payload: endpoint}
				else
					# send req, {:reject, {self, "Protocol mismatch."}}
					send msg.from, %Msg{label: :reject, payload: {self, "Protocol mismatch."}}
					accept(name, check, self, task)
				end
		end

		:global.unregister_name({name, self})
		:ok
	end 

end 