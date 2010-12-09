require 'rubygems'
require 'belphanior/servant/servant_config'
require 'belphanior/servant/servant_config_db'
require 'test/unit'
require 'rack/test'
require 'json'

ENV['RACK_ENV'] = 'test'

class TestServantConfig < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    app.set :servant_config_file, "/tmp/tc_servant_config_out.json"
    app.set :servant_config, ServantConfigDb.new(
<<EOF
  {
    "ip":"127.0.0.1",
    "port": "80"
  }
EOF
    )
  end

  def test_get_all_configs
    get '/config'
    assert_equal 200, last_response.status
    result = JSON.parse(last_response.body)
    assert_equal("127.0.0.1", result["ip"])
    assert_equal("80", result["port"])
  end

  def test_get_specific_config
    get '/config/port'
    assert_equal 200, last_response.status
    assert_equal "80", last_response.body
  end

  def test_write_config
    post '/config/test', "hi"
    assert_equal 200, last_response.status
    get '/config/test'
    assert_equal 200, last_response.status
    assert_equal 'hi', last_response.body
  end
end
