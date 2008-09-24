require 'drb'
require File.dirname(__FILE__)+ '/thermometer.rb'

def log(message)
  puts "#{Time.now.to_i} #{caller.first} #{message}"
end

STDOUT.sync = true

DRb.start_service()
@thermometer=DRbObject.new(nil, 'druby://127.0.0.1:7777')
