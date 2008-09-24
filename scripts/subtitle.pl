#!/usr/bin/perl -w 

$total = shift @ARGV;
$length_per_subtitle = shift @ARGV;
$time_between_subtitles = shift @ARGV;

sub to_time {
    my $time = shift;
    sprintf("%02d:%02d:%02d,000", ($time / 3600) % 60, ($time / 60) % 60, $time % 60);
}

$seconds = $time_between_subtitles;

@lines = <>;
$counter = 0;

while ($seconds <= $total) {
  print "" . to_time($seconds) . " --> " . to_time($seconds + $length_per_subtitle) . "\n";
  $lines[$counter] =~ s/\t+/ /g;
  print $lines[$counter];
  $counter += 1;
  $counter = 0 if $counter >= $#lines;
  print "\n";
  $seconds += $length_per_subtitle + $time_between_subtitles;
}
