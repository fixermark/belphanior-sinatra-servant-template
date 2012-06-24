Gem::Specification.new do |s|
  s.name = %q{belphanior-servant}
  s.version = "0.0.1"
  s.date = %q{2010-12-10}
  s.authors = ["Mark T. Tomczak"]
  s.email = %q{iam+belphanior-servant@fixermark.com}
  s.summary = %q{The Belphanior Servant Template backs Belphanior servants written in Ruby. Specifically, it automatically supports commands and configuration.}
  s.description =  %q{See the documentation for more information. Documentation page coming soon.}
  s.files = [ "belphanior-servant.gemspec",
              "lib/belphanior/servant/belphanior_servant_helper.rb",
              "lib/belphanior/servant/role_builder.rb",
              "lib/belphanior/servant/servant.rb",
              "lib/belphanior/servant/servant_config_db.rb",
              "lib/belphanior/servant/servant_config.rb" ]
  s.add_dependency('json','>= 1.6.1')
  s.add_dependency('sinatra','>= 1.3.1')
  s.test_files = Dir.glob('lib/belphanior/servant/test/tc_*.rb')
end
