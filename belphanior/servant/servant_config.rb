require 'sinatra/base'
require 'belphanior/servant/servant_config_db'

module ServantConfigHelper
  DEFAULT_CONFIG_PATH = "servant_config"
  # Helper function: Tags a text object as a JSON-type
  def self.text_out_as_json(text_representation, status=200)
    [status, {"Content-Type" => "application/json"}, text_representation]
  end
end

module Sinatra
  module ServantConfig
    def self.registered(app)
      app.set :servant_config_file, ServantConfigHelper::DEFAULT_CONFIG_PATH
      app.set :servant_config, ServantConfigDb.new(
<<EOF
  {
    "ip":"127.0.0.1",
    "port": "80"
  }
EOF
      )
      puts "Adding config rule"
      app.get '/config' do
        ServantConfigHelper.text_out_as_json(settings.servant_config.to_json)
      end
      puts "Config rule added."
    end
  end
  register ServantConfig
end
