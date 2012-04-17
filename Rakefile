# -*- ruby -*-
require 'rubygems'
require 'hoe'
require 'rspec/core/rake_task'

# Hoe.plugin :compiler
# Hoe.plugin :gem_prelude_sucks
# Hoe.plugin :inline
# Hoe.plugin :racc
Hoe.plugin :simplecov
# Hoe.plugin :rubyforge

Hoe.spec 'locked-forker' do
  version='0.0.1'
  developer('Joshua Mervine', 'joshua@mervine.net')
end

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

# vim: syntax=ruby
