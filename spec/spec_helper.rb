require_relative '../server'
require 'rack/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods 
end

RSpec::Matchers.define(:redirect_to) do |url|
  match do |response|
    response.status == 302 && response.headers['Location'] == url
  end
end
