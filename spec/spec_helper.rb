require './lib/locked-forker'
require 'fileutils'
require 'pp'

# before all
FileUtils.remove_dir( "/tmp/rspec", true ) if File.directory? "/tmp/rspec"
