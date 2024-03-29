# Copyright 2012 Mark T. Tomczak

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
      name_as_identifier = RoleBuilderUtils::identifier_to_url_component(description["name"])
      description_local_url = "/role_descriptions/" + name_as_identifier
      description_as_json = JSON.generate description
      get description_local_url do
        BelphaniorServantHelper.text_out_as_json(description_as_json)
      end
      role_index = implementation["roles"].length
      implementation["roles"] << {
        "role_url" => "",
        "handlers" => []
      }

      if implementation["roles"][role_index]["role_url"] == "" then
        implementation["roles"][role_index]["role_url"] = (
          "/role_descriptions/" + name_as_identifier)
      end
    end
  end

  register RoleDescriber

  module RoleBuilder
    class BadParameterException < Exception
    end

    def self.empty_handlers
      {
        "roles" => [
        ]
      }
    end

    def self.registered(app)
      app.set :implementation, Sinatra::RoleBuilder.empty_handlers
      app.get '/protocol' do
        BelphaniorServantHelper.text_out_as_json(JSON.dump(app.implementation))
      end

    end

    # Sets the implementation's URL
    def set_role_url(url, role_index=0)
        implementation["roles"][role_index]["role_url"]=url
    end

    # Adds a handler at the specified URL
    #
    # params are
    # - command_name: The identifier for the command this handler implements.
    # - argument_names: The identifiers for the arguments. The command block will receive the arguments in the same order.
    # - http_method: HTTP access method, one of "GET", "POST", etc.
    # - path: The path for the HTTP request (including arguments specified in $(argument name) format).
    # - data: If a POST method, the data that should be sent (including arguments specified in $(argument name) format).
    # - role_index: Which role this handler should be mapped into. Assumes the role already has a description.
    def add_handler(command_name, argument_names, http_method, path, data, role_index=0, &blk)
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

      implementation["roles"][role_index]["handlers"] << new_handler

      # Add the method that will execute for this handler
      sinatra_path = RoleBuilderUtils::arguments_and_path_to_sinatra_path(argument_names, path)
      if http_method == "GET"
        get(sinatra_path, &blk)
      elsif http_method == "POST"
        post(sinatra_path, &blk)
      else
        raise BadParameterException, ("Unknown HTTP method '" + http_method + "'.")
      end
      def clear_handlers
        # Resets the handler list.
        set :implementation, Sinatra::RoleBuilder.empty_handlers
      end
    end
  end
  register RoleBuilder
end
