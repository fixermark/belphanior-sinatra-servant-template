require 'sinatra/base'
require 'belphanior/servant/servant_config_db'

module ServantConfigHelper
  DEFAULT_CONFIG_PATH = "servant_config"
  def self.prepare_config_file(file_path, config)
    if File.exist? file_path
      config_file = File.open(file_path, 'r')
      new_config = ServantConfigDb.new(config_file.read)
      config_file.close
      return new_config
    else
      write_config_file(file_path, config)
      return config
    end
  end
  # Helper function: Tags a text object as a JSON-type
  def self.text_out_as_json(text_representation, status=200)
    [status, {"Content-Type" => "application/json"}, text_representation]
  end
  def self.write_config_file(file_path, config)
    out = File.open(file_path, "w")
    out.write(config.to_json)
    out.close
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
      
      app.get '/config' do
        ServantConfigHelper.text_out_as_json(settings.servant_config.to_json)
      end

      app.get '/config/:name' do
        [200, settings.servant_config.get(params[:name])]
      end

      app.post '/config/:name' do
        old_value = settings.servant_config.get(params[:name])
        begin
          settings.servant_config.set(params[:name], request.body.read)
          ServantConfigHelper.write_config_file(
            settings.servant_config_file, settings.servant_config)
          return [200, old_value]
        rescue ServantConfigException => e
          return [500, "Could not write config: #{e}"]
        end
      end
    end
    def load_servant_config
      set(:servant_config, ServantConfigHelper.prepare_config_file(
        servant_config_file, servant_config))
    end      
  end
  register ServantConfig
end
