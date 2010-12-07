require 'rake'
require 'rake/testtask'
# TODO(mtomczak): Temporary hack while I figure out gem paths
$: << File.dirname(__FILE__)

desc "Run basic tests"
Rake::TestTask::new "test" do |t|
  t.pattern = "belphanior/servant/test/tc*.rb"
  t.verbose = true
  t.warning = true
end

