defmodule Test do 
    defmacro match(a) do
    	quote do
    		is_tuple(unquote(a)) and elem(unquote(a), 0) == :hello
        end 
   	end

   	def test do 
   		send self(), {:hello, 1}
   		send self(), {1, 2}
   		send self(), "slint"

   		receive do 
   			msg when match(msg) -> IO.puts "#{inspect msg}" 
   		end
   	end

end


