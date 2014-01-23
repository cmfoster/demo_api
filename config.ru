require 'rubygems'
require 'bundler/setup'
Bundler.require

root_dir = File.direname(__FILE__)
app_file = File.join(root_dir, 'demo_api.rb')

require app_file

run DemoApi
