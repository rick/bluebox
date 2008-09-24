#!/usr/bin/ruby -w

#
# play media of a given format, based on the current "mood" (derived from thermometer's temperature)
#

$:.unshift(File.dirname(__FILE__)+'/lib/')
require 'thermometer_client'
require 'media'

format = ARGV.shift or raise "usage:  #{__FILE__} <format>"

formats = {
  'music' => Music, 
  'later_music' => LaterMusic,
  'video' => Video,
  'subtitles' => Subtitles, 
  'spoken' => Spoken
}

raise "unknown format [#{format}]" unless formats[format]
log "initialized for format [#{format}]"

player = formats[format].new(@thermometer)
while true
  temperature = @thermometer.temperature
  log "(#{format}) temperature[#{temperature}]"
  player.play(temperature)
end
