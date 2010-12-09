require 'rubygems'
require 'belphanior/servant/servant_config'
require 'belphanior/servant/servant_config_db'
require 'test/unit'
require 'rack/test'
require 'json'

ENV['RACK_ENV'] = 'test'

class TestServantConfig < Test::Unit::TestCase
  include Rack::Test::Methods
  SERVANT_CONFIG_FILE = "/tmp/tc_servant_config_out.json"
  
  def app
    Sinatra::Application
  end

  def setup
    app.set :servant_config_file, SERVANT_CONFIG_FILE
    app.set :servant_config_db, ServantConfigDb.new(
<<EOF
  {
    "ip":"127.0.0.1",
    "port": "80"
  }
EOF
    )
    app.load_servant_config
  end

  def teardown
    if File.exist? SERVANT_CONFIG_FILE
      File.delete SERVANT_CONFIG_FILE
    end
  end

  def test_config_initialize
    validate = File.open(SERVANT_CONFIG_FILE, "r")
    content = JSON.parse(validate.read)
    assert_equal "127.0.0.1", content["ip"]
    assert_equal "80", content["port"]
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
    assert(File.exist? SERVANT_CONFIG_FILE)
    settings_file = File.open(app.servant_config_file, 'r')
    result = JSON.parse(settings_file.read)
    assert_equal 'hi', result["test"]
  end

  def test_readonly_block
    app.servant_config_db.set_readonly('port')
    post '/config/port', '81'
    assert_equal 500, last_response.status
  end
end
