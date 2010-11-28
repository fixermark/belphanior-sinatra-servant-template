require 'ftools'
require 'optparse'
require 'servant_config'
require 'sinatra'

DEFAULT_CONFIG_PATH = "servant_config"
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

set :bind, CONFIG.get("bind")
set :port, CONFIG.get("port")

# To simplify functionality, we make every request handle synchronously.
enable :lock

get '/config/:name' do
  return [200, CONFIG.get(params[:name])]
end

get '/config' do
  return [200, CONFIG.to_json]
end

get '/' do
  "Hello, world!"
end  

