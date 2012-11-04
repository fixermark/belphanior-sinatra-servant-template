require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'rubygems/package_task'

desc "Run basic tests"
Rake::TestTask::new "test" do |t|
  t.pattern = "lib/belphanior/servant/test/tc*.rb"
  t.verbose = true
  t.warning = true
end

desc "Test the empty server"
task :empty do |t|
  puts Gem.path
  puts '---'
  puts $:
  sh "ruby examples/empty.rb"
end

# This builds the actual gem. For details of what all these options
# mean, and other ones you can add, check the documentation here:
#
#   http://rubygems.org/read/chapter/20
#
spec = Gem::Specification.new do |s|
  s.name = %q{belphanior-servant}
  s.version = "0.0.3"
  s.date = %q{2012-10-30}
  s.authors = ["Mark T. Tomczak"]
  s.email = %q{iam+belphanior-servant@fixermark.com}
  s.summary = %q{Support library for Belphanior servants written in Ruby using Sinatra.}
  s.description = IO.read("README")
  s.homepage = "http://belphanior.net"
  s.files = [ "LICENSE",
              "lib/belphanior/servant/belphanior_servant_helper.rb",
              "lib/belphanior/servant/role_builder.rb",
              "lib/belphanior/servant/servant.rb",
              "lib/belphanior/servant/servant_config_db.rb",
              "lib/belphanior/servant/servant_config.rb" ]
  s.licenses = [ "http://www.apache.org/licenses/LICENSE-2.0" ]
  s.add_dependency('json','>= 1.6.1')
  s.add_dependency('sinatra','>= 1.3.1')
  s.test_files = Dir.glob('lib/belphanior/servant/test/tc_*.rb')


end

# This task actually builds the gem. We also regenerate a static
# .gemspec file, which is useful if something (i.e. GitHub) will
# be automatically building a gem for this project. If you're not
# using GitHub, edit as appropriate.
#
# To publish your gem online, install the 'gemcutter' gem; Read more
# about that here: http://gemcutter.org/pages/gem_docs
Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

# If you don't want to generate the .gemspec file, just remove this line. Reasons
# why you might want to generate a gemspec:
#  - using bundler with a git source
#  - building the gem without rake (i.e. gem build blah.gemspec)
#  - maybe others?
task :package => :gemspec

# Generate documentation
Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.rdoc_files.include("README", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end
