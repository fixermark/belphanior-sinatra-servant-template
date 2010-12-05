require 'role_builder'
require 'test/unit'

class TestRoleBuilder < Test::Unit::TestCase
  def test_add_command_fails_on_badparams
    assert_raise Sinatra::RoleBuilder::BadParameterException do
      Sinatra::Application.add_command :usage => "Test"
    end
    assert_raise Sinatra::RoleBuilder::BadParameterException do
      Sinatra::Application.add_command :name => "Test"
    end
  end
end
