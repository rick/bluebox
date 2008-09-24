chvt 3
subtitle=`ls -tr /art/subtitles | tail -1`
/usr/bin/mplayer -quiet -osdlevel 0 -nojoystick -nolirc -nomouseinput -noconsolecontrols -subfont-outline 8 -idx -nooverlapsub -framedrop -menu -sub /art/subtitles/${subtitle} -vo fbdev2 -vf scale=800:600:1 -subpos 92 -double -ss $2 -nosound  $1 >>/art/logs/master.log &
sleep $3
killall mplayer
