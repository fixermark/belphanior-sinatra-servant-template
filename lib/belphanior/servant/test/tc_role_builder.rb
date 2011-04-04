require 'rubygems'
require 'belphanior/servant/role_builder'
require 'test/unit'
require 'rack/test'
require 'json'

ENV['RACK_ENV'] = 'test'

class TestRoleBuilder < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    app.set :roles, [{"description"=>"","commands"=>[]}]
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
                      "data"]
  end

  def test_role_describer_accepts_role_description
    app.add_role_description @default_description
    get '/role_descriptions/test_description'
    assert last_response.ok?
    assert_equal JSON.generate(@default_description), last_response.body
  end
  
  def test_add_handler_adds_handler
    app.add_handler("test command", ["argument 1", "argument 2"], 
      "POST", "/test/$(argument 1)", "$(argument 2)") { |arg1|
      "arg1 is "+arg1+" arg2 is "+(request.body.read)
    }
    post '/test/foo', 'bar'
    assert last_response.ok?
    assert_equal("arg1 is foo arg2 is bar", last_response.body)  
  end

  def test_role_builder_utils_usage_string_to_sinatra_path
    assert_equal "/test/:value/test/:value2",
    RoleBuilderUtils.usage_string_to_sinatra_path(
      "/test/$(value)/test/$(value2)")
  end

  def test_add_handler_fails_on_badparams
    # TODO(mtomczak): implement
  end

  def test_identifier_case_insensitivity
    app.add_handler("My command", ["Cap"], "GET", "path", "data") do end
    # TODO(mtomczak): Check /protocol and compare to expected lowercase outputs
    # result = JSON.parse(app.get_roles)
    # assert_equal "my command", result[0]["commands"][0]["name"]
    # assert_equal "cap", result[0]["commands"][0]["arguments"][0]["name"]
  end

  def test_handler_binding_unknown_http_method
    # TODO(mtomczak): verify that HTTP method "FOO" raises an exceptino
  end

  # TODO(mtomczak): Add test to
  # * verify behavior on bad parameters
  # * verify that adding rule properly configures /protocol
  # TODO(mtomczak): Strip all following tests

  def test_add_command_fails_on_badparams
    assert_raise Sinatra::RoleBuilder::BadParameterException do
      app.add_command :usage => "Test" do end
    end
    assert_raise Sinatra::RoleBuilder::BadParameterException do
      app.add_command :name => "Test" do end
    end
  end
end
