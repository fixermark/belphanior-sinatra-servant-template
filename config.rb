# Configuration management library
# Manages key-value pair configurations and their serialization to JSON
# keys and values are strings

require 'json'

class ConfigException < RuntimeError
end

class Config
  def initialize(json_string)
    @config = JSON.parse(json_string)
    # validation: @config is a hash, keys are strings, vals are strings
    if (@config.class != {}.class)
      raise ConfigException, 
      "Config error: JSON string did not evaluate to an object",
      caller
    end
    @config.each{|key, value|
      if (value.class != "".class)
        raise ConfigException,
        ("Config error: JSON initialization string,"
         "value for key '#{key}' is type '#{value.class}'"),
        caller
      end
    }
    @config.default ""
  end

  def get(key)
    @config[key]
  end
  def to_json
    JSON.dump(@config)
  end
end

# TODO: Write tests for config library
