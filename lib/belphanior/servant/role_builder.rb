require 'json'
require 'sinatra/base'
require 'belphanior/servant/belphanior_servant_helper'

module RoleBuilderUtils
  # converts Belphanior-style "$(arg)" arguments to Sinatra-style
  # ":arg" specifiers
  def self.usage_string_to_sinatra_path(usage)
    output = ""
    usage.split("$").each { |substring|
      if substring[0,1]=="("
        substring[0]=":"
        remainder_array = substring.split(")")
        
        output += (substring.split(")").join)
      else
        output += substring
      end
    } 
    output
  end
  def self.arguments_and_path_to_sinatra_path(arguments, path)
    arguments.each { |arg|
      path = path.sub("$("+arg+")", ":"+identifier_to_url_component(arg))
    }
    path
  end
  def self.is_valid_identifier?(identifier)
    identifier =~ /^[a-zA-Z][a-zA-Z0-9 ]*$/
  end
  def self.normalize_identifier(identifier)
    identifier.downcase
  end
  def self.identifier_to_url_component(identifier)
    identifier.gsub(/ /,"_").downcase
  end
end

module Sinatra

  module RoleDescriber
    class BadParameterException < Exception
    end
    
      # Adds a new role description. Note: this is a VERY quick-and-dirty hack;
    # the added description isn't vetted for format conformance at all.
    def add_role_description(description)
      if not RoleBuilderUtils::is_valid_identifier?(description["name"])
        raise BadParameterException, "Role name was not a valid identifier."
      end
      description_as_json = JSON.generate description
      get('/role_descriptions/' + 
        RoleBuilderUtils::identifier_to_url_component(
        description["name"])) do
        BelphaniorServantHelper.text_out_as_json(description_as_json)
      end
    end
  end

  register RoleDescriber

  module RoleBuilder
    class BadParameterException < Exception
    end
    def self.registered(app)
      app.set :roles, [{"name"=>"unnamed","description"=>"TODO: Fill this in", "commands"=>[] }]
      app.set :implementation, [{"role_url"=>"", "handlers"=>[]}]
      app.get '/protocol' do
        BelphaniorServantHelper.text_out_as_json(get_implementation)
      end

    end

    # Sets the implementation's URL
    def set_role_url(url)
        implementation["role_url"]=url
    end

    # Adds a handler at the specified URL
    #
    # params are
    # - command_name: The identifier for the command this handler implements.
    # - argument_names: The identifiers for the arguments. The command block will receive the arguments in the same order.
    # - http_method: HTTP access method, one of "GET", "POST", etc.
    # - path: The path for the HTTP request (including arguments specified in $(argument name) format).
    # - data: If a POST method, the data that should be sent (including arguments specified in $(argument name) format).
    def add_handler(command_name, argument_names, http_method, path, data, &blk)
      # validate name, args, and method
      if not RoleBuilderUtils::is_valid_identifier? command_name
        raise BadParameterException, (command_name + " is not a valid command name.")
      end
      argument_names.each { |i|
        if not RoleBuilderUtils::is_valid_identifier? i
          raise BadParameterException, (i + " is not a valid argument name.")
        end
      }
      if not ["GET", "POST", "PUT", "DELETE"].include? http_method
        raise BadParameterException, (http_method + " is not a valid HTTP method (is it capitalized?)")
      end

      new_handler = {
        "name" => RoleBuilderUtils::normalize_identifier(command_name),
        "method" => http_method,
        "path" => path,
        "data" => data
      }
      implementation["handlers"] << new_handler

      # Add the method that will execute for this handler
      sinatra_path = RoleBuilderUtils::arguments_and_path_to_sinatra_path(argument_names, path)
      if http_method == "GET"
        get(sinatra_path, &blk)
      elsif http_method == "POST"
        post(sinatra_path, &blk)
      else
        raise BadParameterException, ("Unknown HTTP method '" + http_method + "'.")
      end
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
      if new_command_method == "GET"
        get(sinatra_path, &blk)
      elsif new_command_method == "POST"
        post(sinatra_path, &blk)
      else
        (raise BadParameterException, 
         "Unknown method '"+new_command_method+"'.")
      end
    end

    def get_roles()
      JSON.dump roles
    end
  end
  register RoleBuilder
end
