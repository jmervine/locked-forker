# -*- ruby -*-
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rspec/core/rake_task'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "locked-forker"
  gem.homepage = "http://github.com/jmervine/locked-forker"
  gem.license = "MIT"
  gem.summary = %Q{ Locks and forks your code. }
  gem.description = %Q{ Utilities to lock and fork code for those that want to fork calls, but ensure that no one will run that code until the fork completes. }
  gem.email = "joshua@mervine.net"
  gem.authors = ["Joshua Mervine"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("History.txt", "Manifest.txt", "VERSION", "lib/**/*.rb")
end

desc "Tasks to finalize an update."
task :submit do 
  puts "Running rSpec tests"
  Rake::Task['spec'].invoke
  puts "Generating rDocs."
  Rake::Task['rerdoc'].invoke
  # push current branch
  Rake::Task['git:ci'].invoke
  # tagging current branch
  #  and pushing the tag to origin
  puts "Tagging and pushing."
  Rake::Task['git:release'].invoke
end

namespace :git do

  task :ci do
    # don't run this manually, it should be run as part of 'submit'
    puts "Commiting rdocs and gemspec."
    Rake::Task['gemspec'].invoke
    %x{ git commit -a -m "updating rdocs and gemspec" }
  end
end

# vim: syntax=ruby
