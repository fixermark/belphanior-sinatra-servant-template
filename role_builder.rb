require 'json'
require 'sinatra/base'

module Sinatra
  module RoleBuilder
    def self.registered(app)
      app.set :roles, [{"description"=>"TODO: Fill this in", "commands"=>[] }]
    end

    # TODO: vet identifiers
    def add_command(params)
      name = params[:name] || raise("Name parameter is required.")
      description = params[:description]
      arguments = params[:arguments]
      return_info = params[:return]
      usage = params[:usage] || raise("Must specify usage for #{name}")
      
      new_command = {"name"=>name}
      if description
        new_command["description"] = description
      end

      new_command["arguments"]=[]
      arguments.each do |arg|
        argument = {"name"=>arg[0]}
        if arg.length > 1
          argument["description"] = arg[1]
        end
        new_command["arguments"] << argument
      end

      if return_info
        new_command["return"] = {"description" => return_info}
      end

      new_command["usage"] = {
        "method" => usage[0],
        "path" => usage[1],
        "data" => usage[2]
      }
      
      roles[0]["commands"] << new_command
    end

    def get_roles()
      JSON.dump roles
    end
  end
  register RoleBuilder
end
