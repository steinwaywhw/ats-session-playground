

defmodule Session do

end

defmodule Channel do 

	
end 

defmodule Endpoint do

	def create(pid) do 
		spawn fn -> loop(pid) end 
	end 

	def 

	defp loop(pid) do 
		receive do 
			{:send, requester, X, Y, msg}
			{:recv, requester, X, Y}
			{:close, requester}

			{:identify, requester} -> 
				send requester, pid
				loop pid 
		end 
	end 
end 


