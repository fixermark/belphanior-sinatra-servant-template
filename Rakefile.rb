require 'rubygems'
require 'rake'
require 'rake/testtask'
# TODO(mtomczak): Temporary hack while I figure out gem paths
$: << File.dirname(__FILE__)+"/lib"
Gem.path << File.dirname(__FILE__)

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
