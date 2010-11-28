require 'config'
require 'json'
require 'test/unit'

class TestConfig < Test::Unit::TestCase
  def setup
    @config = Config.new(
<<EOF
  {
    "ip":"127.0.0.1",
    "port": "80"
  }
EOF
    )
  end
  def test_initialization
    assert_equal(@config.get("ip"),"127.0.0.1")
    assert_equal(@config.get("port"), "80")
  end
  def test_serialization
    out = JSON.parse(@config.to_json)
    assert_equal(out.length, 2)
    assert_equal(out["ip"],"127.0.0.1")
    assert_equal(out["port"], "80")
  end
  def test_set
    @config.set("bar","hi")
    assert_equal(@config.get("bar"),"hi")
    @config.set("number_of_pigs",3)
    assert_equal(@config.get("number_of_pigs"),"3")
  end
  def test_readonly
    @config.set_readonly("ip")
    assert(@config.is_readonly("ip"), true)
    assert_raises (ConfigException) {
      @config.set("ip","127.0.0.10")
    }
  end
end

