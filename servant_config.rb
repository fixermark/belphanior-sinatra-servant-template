# Configuration management library
# Manages key-value pair configurations and their serialization to JSON
# keys and values are strings

require 'json'

class ServantConfigException < RuntimeError
end

class ServantConfig
  def initialize(json_string)
    @config = JSON.parse(json_string)
    # validation: @config is a hash, keys are strings, vals are strings
    if (@config.class != {}.class)
      raise ServantConfigException, 
      "ServantConfig error: JSON string did not evaluate to an object",
      caller
    end
    @config.each{|key, value|
      if (value.class != "".class)
        raise ServantConfigException,
        ("ServantConfig error: JSON initialization string,"
         "value for key '#{key}' is type '#{value.class}'"),
        caller
      end
    }
    @config.default ""
    @readonly = []
  end

  def to_json
    JSON.dump(@config)
  end

  def get(key)
    @config[key]
  end

  def set(key, value)
    key = key.to_s
    value = value.to_s
    if @readonly.include? key
      raise ServantConfigException,
      "Attempted to change read-only property '#{key}'",
      caller
    end
    @config[key]=value
  end

  def is_readonly(key)
    @readonly.include? key
  end

  def set_readonly(key)
    @readonly << key
  end
end

# TODO: Write tests for config library
