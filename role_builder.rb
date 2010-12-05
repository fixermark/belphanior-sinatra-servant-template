require 'json'
require 'sinatra/base'

module Sinatra
  module RoleBuilder
    class BadParameterException < Exception
    end
    def self.registered(app)
      app.set :roles, [{"description"=>"TODO: Fill this in", "commands"=>[] }]
    end

    # Adds a command to the role, and registers the
    # params are
    # -name: Name of the command
    # -description: COmmand's description (optional)
    # -arugments: Arguments to the command, which is a list of tuples (name,
    #  description). Description is optional.
    # -return: Description of the return value, if any. Optional.
    # -usage: HTTP usage description. A triple of
    # -- method ("get", "post", etc.)
    # -- path ("/object/${my_object}")
    # -- data ("${my_data}")
    def add_command(params)
      name = params[:name] || 
        (raise BadParameterException, "Name parameter is required.")
      description = params[:description]
      arguments = params[:arguments] || []
      return_info = params[:return]
      usage = params[:usage] || 
        (raise BadParameterException, "Must specify usage for #{name}")
      
      new_command = {"name" => (name.downcase)}
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
