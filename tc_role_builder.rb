require 'role_builder'
require 'test/unit'
require 'json'

class TestRoleBuilder < Test::Unit::TestCase
  def test_add_command_fails_on_badparams
    assert_raise Sinatra::RoleBuilder::BadParameterException do
      Sinatra::Application.add_command :usage => "Test"
    end
    assert_raise Sinatra::RoleBuilder::BadParameterException do
      Sinatra::Application.add_command :name => "Test"
    end
  end

  def test_add_command_adds_to_roles
    Sinatra::Application.add_command( 
      :name => "Test",
      :description => "My test data.",
      :arguments => [["arg1","An argument"],["arg2"]],
      :return => "Test return.",
      :usage => ["get",
                 "/path/to/test",
                 "my_data"])
    result = JSON.parse(Sinatra::Application.get_roles)
    command = result[0]["commands"][0]
    assert_equal command["name"], "Test"
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
    #TODO(mtomczak): this test.
  end
end
