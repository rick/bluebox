#!/usr/bin/ruby -w

#
# for some reason unknown, motion will not properly intialize on its first run, never
# collecting camera input(!).  We reset it shortly after boot.
#

rebooted = File.mtime('/tmp/last_rebooted')
puts "delayed reboot -- last reboot time [#{rebooted.to_s}]"
raise "Not yet safe to restart motion!" unless Time.now - rebooted > 90
raise "Motion has already been restarted!" if File.exists?('/tmp/last_reset') and File.mtime('/tmp/last_reset') > rebooted

`/art/scripts/reset`
`touch /tmp/last_reset`
