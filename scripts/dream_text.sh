#!/bin/sh
cat /art/text/ali_dreams.txt | sed 's:^[0-9]\+ \+[0-9]\+ \+::' | /art/scripts/wrap 175 | /art/scripts/shuffle | /art/scripts/reformat_lines.sh
