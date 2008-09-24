class Subtitles < Media
  def initialize(thermometer)
    @buckets = [:dream, :poem]
  
    @params = {
      :dream  => { :sleep => 1, :sleep_shift => 0, :duration => 19,  :duration_shift => 0, :visible => 10, :space => 6 },
      :poem   => { :sleep => 1, :sleep_shift => 0, :duration => 90,  :duration_shift => 0, :visible => 5, :space => 3 },
    }
    super
  end

  def media(bucket)
    [bucket]
  end

  def play_single(piece)
    file = "/art/subtitles/subtitles.#{Time.now.to_i}"
    log "(subtitles) now writing to #{file}"
    command = "/bin/sh /art/scripts/#{piece}_text.sh | /usr/bin/perl /art/scripts/subtitle.pl 7200 #{@params[piece][:visible]} #{@params[piece][:space]} > #{file}"
    log "(subtitles) running [#{command}]"
    `#{command}`
    sleep @params[piece][:duration]
  end
end
