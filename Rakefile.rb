require 'rake'
require 'rake/testtask'

desc "Run basic tests"
Rake::TestTask::new "test" do |t|
  t.pattern = "belphanior/servant/tc*.rb"
  t.verbose = true
  t.warning = true
end

