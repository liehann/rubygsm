# import the main library, and
# a mock modem to test against
here = File.dirname(__FILE__)
require "#{here}/../lib/rubygsm.rb"
require "#{here}/mock/modem.rb"
require 'mocha'

RSpec.configure do |config|
  config.mock_with :mocha
end

