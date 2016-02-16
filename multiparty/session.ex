



defmodule SessionData do 
	defstruct self: nil, parties: %{}
end

defmodule EndpointData do 
	defstruct self: nil, pid: nil, ref: nil
end




defmodule Message do 

end


defmodule Endpoint do 

	def create(self) do 
		%EndpointData{self: self, ref: make_ref(), pid: spawn fn -> init(self) end}
	end 

	def send() do 
	end 

	def receive() do 
	end 

	def choose() do 
	end 

	def offer() do 
	end 

	def close(session) do 
		nil
	end 

	def link() do 
	end 


	def init(self) do 
		receive do 
			{:init, %SessionData{self: ^self} = session} -> loop session
		end
	end 


	defp loop(session) do 
		IO.puts "#{inspect session}"
	end
end


defmodule Session do 

	defstruct self: nil, parties: %{}

	def make_name(name) do 
		String.to_atom name
	end 

	defp init(session) do 
		f = fn({party, %EndpointData{self: self, pid: pid, ref: ref}}) -> 
			send pid, {:init, %SessionData{session | self: party}}
		end

		Enum.each(session.parties, f)
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
			send parent_pid, {:request, self(), {name, gp}}
			receive do
				{:accept, %EndpointData{self: ^party} = endpoint} -> {endpoint.self, endpoint}
				{:reject, {^party, reason}} -> raise "Request rejected: #{party} - #{reason}"
			end
		end

		# [{party, parent_pid}] |> [{party, endpoint}] |> %{party, endpoint} ++ %{self, endpoint}
		parties = Enum.map(pids, f) |> Map.new |> Map.put(self, Endpoint.create(self))

		# init all parties
		session = %SessionData{self: self, parties: parties}
		init session

		# return endpoint
		session.parties[session.self]
	end 


	def accept(name, check, self, task) do 

		# register {name, party}
		ret = :global.register_name({name, self}, self())
		if ret == :no, do: raise "Registering #{name} for #{self} => #{self()} failed."

		receive do 
			{:request, req, {^name, gp}} -> 

				# check protocol
				if check.(gp) do
					endpoint = Endpoint.create self
					spawn fn -> task.(endpoint) end
					send req, {:accept, endpoint}
				else
					send req, {:reject, {self, "Protocol mismatch."}}
					accept(name, check, self, task)
				end
		end

		nil
	end 

end 