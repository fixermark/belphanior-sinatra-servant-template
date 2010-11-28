require 'sinatra'

# To simplify functionality, we make every request handle synchronously.
enable :lock

get '/' do
  "Hello, world!"
end  

