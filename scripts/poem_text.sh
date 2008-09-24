#!/bin/sh

last_subtitle=`/bin/ls /art/subtitles | /usr/bin/tail -1`
random_word=`/art/scripts/shuffle /usr/share/dict/words | head -1`
topic=`/usr/bin/tail -2 /art/subtitles/${last_subtitle} | /art/scripts/wrap 1000 |  perl -ne 's/^.*\s+(\S)/\1/; s/[?!\.]\s*$//; print "$_\n";'`
topic=${topic:-${random_word}}
/art/scripts/blackbox-poem --link 2 --source /art/text/all.sorted --lines 200 --topic ${topic} | /art/scripts/wrap 200 | /art/scripts/reformat_lines.sh
