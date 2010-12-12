require 'rubygems'
require 'ftools'
require 'optparse'
require 'belphanior/servant/servant_config'
require 'belphanior/servant/role_builder'
require 'sinatra'

OptionParser.new { |opts|
  opts.on('-c', '--config-file', 
          'Specify the configuration file for the servant.') do |file|
    set :servant_config_file, file
  end
}

def init
  load_servant_config

  # readonly because changing them involves rebooting the server, so the
  # change cannot be honored.
  servant_config.set_readonly "bind"
  servant_config.set_readonly "port"

  set :bind, servant_config.get("bind")
  set :port, servant_config.get("port")

  # To simplify functionality, we make every request handle synchronously.
  enable :lock

  # default handler for top-level index. A user-defined top-level index
  # created before servant.init is called would override this.
  get '/' do
    server_name = servant_config.get("server_name") || "<TODO: set name>"
    <<EOF
<html>
  <head>
  <title>Belphanior Servant: #{server_name}</title>
  </head>
  <body>
    <h1>Belphanior Servant Online</h1>
    <h2>#{server_name}</h2>
    <p>Hello! I am #{server_name}, and I am happy to serve you.</p>
    <p>To learn more about what I can do, check my 
       <a href="/protocol">protocol</a>.</p>
    <p>Want to know my settings? Check my <a href="/config">config</a>.
  </body>
EOF
  end  
end

# To add commands, use the following style:
# add_command(
#            :name => "test",
#            :description => "Test command.",
#            :arguments => [["test arg 1"], ["test arg 2","test description"]],
#            :return => "None.",
#            :usage => ["GET", "/hi/everybody", ""])
