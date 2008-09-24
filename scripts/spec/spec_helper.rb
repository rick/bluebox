$:.unshift(File.dirname(__FILE__)+'/../lib/')

require 'mocha'

# activate Mocha-style mocking
Spec::Runner.configure do |config|
  config.mock_with :mocha
end
