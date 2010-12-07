require 'json'
require 'sinatra/base'

module RoleBuilderUtils
  # converts Belphanior-style "$(arg)" arguments to Sinatra-style
  # ":arg" specifiers
  def self.usage_string_to_sinatra_path(usage)
    output = ""
    usage.split("$").each { |substring|
      if substring[0,1]=="("
        substring[0]=":"
        output += (substring.split(")").join)
      else
        output += substring
      end
    } 
    output
  end
end

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
    def add_command(params, &blk)
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
        argument = {"name" => arg[0].downcase}
        if arg.length > 1
          argument["description"] = arg[1]
        end
        new_command["arguments"] << argument
      end

      if return_info
        new_command["return"] = {"description" => return_info}
      end
      
      new_command_method = usage[0]
      new_command_path = usage[1]
      new_command_data = usage[2]
      new_command["usage"] = {
        "method" => new_command_method,
        "path" => new_command_path,
        "data" => new_command_data
      }
      
      roles[0]["commands"] << new_command

      sinatra_path = RoleBuilderUtils.usage_string_to_sinatra_path(
        new_command_path)
      if new_command_method == "get"
        get(sinatra_path, &blk)
      elsif new_command_method == "post"
        post(sinatra_path, &blk)
      end
    end

    def get_roles()
      JSON.dump roles
    end
  end
  register RoleBuilder
end