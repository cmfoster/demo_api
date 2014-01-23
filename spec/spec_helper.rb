require 'rack/test'
require 'database_cleaner'
require 'timecop'

require File.expand_path '../../demo_api.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure do |config|
  config.include RSpecMixin

  # Because this is a demo application I did not feel the need to setup a test database.
  DatabaseCleaner.strategy = :truncation
  config.before(:each) do
    DatabaseCleaner.clean
  end
end
