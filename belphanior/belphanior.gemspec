Gem::Specification.new do |s|
  s.name = %q{belphanior-servant-template}
  s.version = "0.0.1"
  s.date = %q{2010-12-10}
  s.authors = ["Mark T. Tomczak"]
  s.email = %q{iam+belphanior-servant@fixermark.com}
  s.summary = %q{The Belphanior Servant Template backs Belphanior servants written in Ruby. Specifically, it automatically supports commands and configuration.}
  s.description =  %q{See the documentation for more information. Documentation page coming soon.}
  s.files = [ "servant/belphanior_servant_helper.rb",
              "servant/role_builder.rb",
              "servant/servant_config_db.rb",
              "servant/servant_config.rb" ]
  s.test_files = Dir.glob('test/tc_*.rb')
end
