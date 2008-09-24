#!/usr/bin/ruby -w

#
# Read output from Motion camera events and update shared Thermometer accordingly
#

$:.unshift(File.dirname(__FILE__)+'/lib/')
require 'thermometer_client'

# how much does each camera contribute to activity?
weight = {
  1 => 2,
  2 => 5
}

count = 0
log "reading camera data..."

file = File.open('/art/tmp/camera_motion')
while File.exists?(file.path) 
  if File.size(file.path) < file.pos
    log "File truncated -  reopening."
    @thermometer.activity(-10000000)
    file = File.open(file.path)
  end
  saw_something = false
  while !file.eof?
    saw_something = true
    line = file.gets.chomp
    timestamp, camera, *message = line.split(/\s+/)
    @thermometer.activity(weight[camera.to_i])
    log "read [#{line}] adding [#{weight[camera.to_i]}] to activity"
    log "temperature now [#{@thermometer.temperature}]"
  end
  unless saw_something
    log "sleeping [count #{count}]..." if((count += 1) % 60) == 0
    sleep 1
  end
end
