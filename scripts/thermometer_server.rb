#!/usr/bin/ruby -w

$:.unshift(File.dirname(__FILE__)+'/lib/')
require 'thermometer'
require 'drb'

#
# Thermometer server -- makes a Thermometer instance available via DRb
#

#$DEBUG = 1
remote_path = 'druby://127.0.0.1:7777'
puts "Starting Thermometer server (listening on [#{remote_path}])."
DRb.start_service(remote_path, Thermometer.new(:upper_limit => 7500))
DRb.thread.join
