require 'rubygems'
require 'belphanior/servant/role_builder'
require 'test/unit'
require 'rack/test'
require 'json'

ENV['RACK_ENV'] = 'test'

# Test helper function
# Validates that two JSON-style objects are equivalent
# Equivalence is defined as follows:
#   Array type: each element equivalent
#   Dict type: For each key |k| in reference, key in value
#    exists and value for the key is equivalent.
#    NOTE: This means that the input can contain
#    additional data, and this is acceptable.
#   All others: Simple ruby equivalence.
def assert_equivalent_json_objects(reference, tested)
  assert_equal(reference.class(), tested.class())
  if reference.class() == [].class()
    assert_equal(reference.length, tested.length)
    for i in 0..reference.length
      assert_equivalent_json_objects(
        reference[i], tested[i])
    end
  elsif reference.class() == {}.class()
    reference.each do |key, value|
      assert_equal(true, tested.has_key?(key))
      assert_equivalent_json_objects(value, tested[key])
    end
  else
    # String or number (or other type): value compare
    assert_equal(reference, tested)
  end
end


class TestRoleBuilder < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    app.set :roles, []
    @default_description = {
      "name" => "test description",
      "description" => "An example of a role description.",
      "commands" => [
        {
          "name" => "test command",
          "description" => "An example command.",
          "arguments" => [
            {
              "name" => "test arg",
              "description" => "An example argument."
            }
          ]
        }
      ]
    }
    @default_usage = [
      "GET",
      "/path",
      "data"
    ]
  end

  def teardown
    app.clear_handlers
  end

  def test_role_describer_accepts_role_description
    app.add_role_description @default_description
    get '/role_descriptions/test_description'
    assert last_response.ok?
    assert_equal JSON.generate(@default_description), last_response.body
  end

  def test_add_handler_adds_handler
    app.add_role_description @default_description
    app.add_handler("test command", ["argument 1", "argument 2"],
      "POST", "/test/$(argument 1)", "$(argument 2)") { |arg1|
      "arg1 is "+arg1+" arg2 is "+(request.body.read)
    }
    post '/test/foo', 'bar'
    assert last_response.ok?
    assert_equal("arg1 is foo arg2 is bar", last_response.body)
  end

  def test_add_handler_updates_protocol
    app.add_role_description @default_description
    app.set_role_url("/test")
    app.add_handler("test command", ["argument 1"], "GET", "/test/$(argument 1)", "") {|arg1|}
    get '/protocol'
    assert_equal(200, last_response.status)
    assert_equivalent_json_objects(
      {
        "roles" => [{
          "role_url" => "/test",
          "handlers" => [{
            "name" => "test command",
            "method" => "GET",
            "path" => "/test/$(argument 1)"}]
      }]},
      JSON.parse(last_response.body))
  end

  def test_role_builder_utils_usage_string_to_sinatra_path
    assert_equal "/test/:value/test/:value2",
    RoleBuilderUtils.usage_string_to_sinatra_path(
      "/test/$(value)/test/$(value2)")
  end

  def test_identifier_case_insensitivity
    app.add_role_description @default_description
    app.set_role_url "/test"
    app.add_handler("My command", ["Cap"], "GET", "path", "data") do end
    get '/protocol'
    assert_equal(200, last_response.status)
    assert_equivalent_json_objects(
      {
        "roles" => [{
          "role_url" => "/test",
          "handlers" => [{
            "name" => "my command",
            "method" => "GET",
            "path" => "path",
            "data" => "data"}]
      }]},
      JSON.parse(last_response.body))
  end
  def test_multi_role
    app.add_role_description @default_description
    app.add_role_description({
        "name" => "second role",
        "description" => "An example of a role description.",
        "commands" => [
          {
            "name" => "test command 2",
            "description" => "An example command.",
            "arguments" => [
              {
                "name" => "test arg b",
                "description" => "An example argument."
              }
            ]
          }
        ]
      }
      )
    app.add_handler("test command", ["test arg"],
      "POST", "/test2/$(test arg)", "", 0) { |arg1|
      "arg1 is " + arg1
    }
    app.add_handler("test command 2", ["test arg b"],
      "GET", "/test3/$(test arg b)", "", 1) { |arg1|
      "arg1b is " + arg1
    }

    post '/test2/foo', ""
    assert last_response.ok?
    assert_equal("arg1 is foo", last_response.body)

    get '/test3/bar'
    assert last_response.ok?
    assert_equal("arg1b is bar", last_response.body)
  end
end
