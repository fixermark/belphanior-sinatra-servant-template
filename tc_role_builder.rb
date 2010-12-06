require 'rubygems'
require 'role_builder'
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
    @default_usage = [
                      "get",
                      "/path",
                      "data"]
  end

  def test_role_builder_utils_usage_string_to_sinatra_patch
    assert_equal "/test/:value/test/:value2",
    RoleBuilderUtils.usage_string_to_sinatra_path(
      "/test/$(value)/test/$(value2)")
  end

  def test_add_command_fails_on_badparams
    assert_raise Sinatra::RoleBuilder::BadParameterException do
      app.add_command :usage => "Test"
    end
    assert_raise Sinatra::RoleBuilder::BadParameterException do
      app.add_command :name => "Test"
    end
  end

  def test_add_command_adds_to_roles
    app.add_command( 
      :name => "test",
      :description => "My test data.",
      :arguments => [["arg1","An argument"],["arg2"]],
      :return => "Test return.",
      :usage => ["get",
                 "/path/to/test",
                 "my_data"])
    result = JSON.parse(app.get_roles)
    command = result[0]["commands"][0]
    assert_equal command["name"], "test"
    assert_equal command["description"], "My test data."
    assert_equal command["arguments"][0]["name"], "arg1"
    assert_equal command["arguments"][0]["description"], "An argument"
    assert_equal command["arguments"][1]["name"], "arg2"
    assert_equal command["return"]["description"], "Test return."
    assert_equal command["usage"]["method"], "get"
    assert_equal command["usage"]["path"], "/path/to/test"
    assert_equal command["usage"]["data"], "my_data"
  end

  def test_identifier_case_insensitivity
    app.add_command(
      :name => "My command",
      :arguments => [["Cap"]],
      :usage => ["get",
                 "/path",
                 "data"])
    result = JSON.parse(app.get_roles)
    assert_equal "my command", result[0]["commands"][0]["name"]
    assert_equal "cap", result[0]["commands"][0]["arguments"][0]["name"]
  end

  def test_command_binding
    app.add_command(
      :name => "test command binding",
      :arguments => [["arg1"]],
      :return => "Some stuff.",
      :usage => [
                 "get",
                 "/test_command_binding/$(arg1)/success",
                 ""]
                    ) do
      ("Output is " + params[:arg1])
    end
#    get '/test_command_binding/foo/success'
#    assert last_response.ok?
#    assert_equal "Output is foo", last_response.body
  end
end
