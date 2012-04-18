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
task :submit, :tag do |t,p|
  puts "Running rSpec tests"
  Rake::Task['spec'].invoke
  puts "Generating rDocs."
  Rake::Task['rerdoc'].invoke
  # push current branch
  Rake::Task['git:push'].invoke
  # tagging current branch
  #  and pushing the tag to origin
  Rake::Task['git:tag'].invoke(p[:tag])
end

namespace :git do

  desc "Git push."
  task :push do |task, params|
    puts "Running git push on current branch."
    %x{ git push }
  end

  desc "Git tag."
  task :tag, :tag do |t, p|
    puts "usage: rake git:tag <tag_name>" and exit unless p[:tag]
    puts "Tagging current branch with #{p[:tag]} and pushing the tag to origin."
    %x{ git tag -f #{p[:tag]} && git push origin #{p[:tag]} }
  end

  task :ci do
    # don't run this manually, it should be run as part of 'submit'
    puts "Commiting rdocs and gemspec."
    Rake::Task['gemspec'].invoke
    %x{ git commit -a -m "updating rdocs and gemspec" }
  end
end

# vim: syntax=ruby
