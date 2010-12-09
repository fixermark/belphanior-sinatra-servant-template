require 'ftools'
require 'optparse'
require 'servant_config'
require 'sinatra'
require 'json_out'

DEFAULT_CONFIG = <<EOF
{
  "bind" : "127.0.0.1",
  "port" : "3000"
}
EOF
COMMAND_LINE={}

OptionParser.new { |opts|
  opts.on('-c', '--config-file', 
          'Specify the configuration file for the servant.') do |file|
    COMMAND_LINE[:config] = file
  end
}

if not COMMAND_LINE.include? :config
  COMMAND_LINE[:config] = DEFAULT_CONFIG_PATH
end

if not File.exists? COMMAND_LINE[:config]
  out = File.open(COMMAND_LINE[:config], File::WRONLY|File::CREAT, 0660)
  out << DEFAULT_CONFIG
  out.close
end

config_string = File.read(COMMAND_LINE[:config])

CONFIG = ServantConfig.new(config_string)
CONFIG.set_readonly "bind"
CONFIG.set_readonly "port"

set :bind, CONFIG.get("bind")
set :port, CONFIG.get("port")

# To simplify functionality, we make every request handle synchronously.
enable :lock

def write_config_file
  out = File.open(COMMAND_LINE[:config], "w")
  out.write(CONFIG.to_json)
  out.close
end

post '/config/:name' do
  old_value = CONFIG.get(params[:name])
  begin
    CONFIG.set(params[:name], request.body.read)
    write_config_file
    return [200, old_value]
  rescue ServantConfigException => e
    return [500, "Could not write config: #{e}"]
  end
end

def add_route()
  get '/test' do
    "Test worked!"
  end
end

get '/' do
  add_route
  "Hello, world!"
end  

require 'role_builder'
add_command(
            :name => "test",
            :description => "Test command.",
            :arguments => [["test arg 1"], ["test arg 2","test description"]],
            :return => "None.",
            :usage => ["GET", "/hi/everybody", ""])




get '/protocol' do
  text_out_as_json(get_roles)
end
