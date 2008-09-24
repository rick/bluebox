class LaterMusic < Media
  def initialize(thermometer)
    @buckets = [:blank, :blank, :blank, :ecstatic, :ecstatic]
  
    @params = {
      :blank    => { :sleep => 45, :sleep_shift => -5, :duration => 20, :duration_shift => 40 },
      :quiet    => { :sleep => 45, :sleep_shift => -5, :duration => 140, :duration_shift => 40 },
      :lonely   => { :sleep => 20, :sleep_shift =>  2, :duration => 90,  :duration_shift => 10 },
      :upbeat   => { :sleep => 10, :sleep_shift =>  0, :duration => 90,  :duration_shift =>  0 },
      :ecstatic => { :sleep => 5,  :sleep_shift =>  2, :duration => 45,  :duration_shift =>  0 },
      :freaked  => { :sleep => 0,  :sleep_shift =>  0, :duration => 30,  :duration_shift =>  0 }
    }
    super
  end

  def media(bucket)
    Dir["/art/music/#{bucket}/*.mp3"]
  end

  def play_single(piece)
    log "(later_music) now playing [#{piece}]"
    if piece and File.exists?(piece)
      `/usr/bin/mpg123-esd #{piece}` 
    else
      sleep 1
    end
  end
end
