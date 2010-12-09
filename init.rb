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

load_servant_config

servant_config.set_readonly "bind"
servant_config.set_readonly "port"

set :bind, servant_config.get("bind")
set :port, servant_config.get("port")

# To simplify functionality, we make every request handle synchronously.
enable :lock

get '/' do
  "Hello, world!"
end  


add_command(
            :name => "test",
            :description => "Test command.",
            :arguments => [["test arg 1"], ["test arg 2","test description"]],
            :return => "None.",
            :usage => ["GET", "/hi/everybody", ""])
