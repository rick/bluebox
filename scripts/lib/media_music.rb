class Music < Media
  def initialize(thermometer)
    @buckets = [:quiet, :lonely, :upbeat, :ecstatic, :freaked]
  
    @params = {
      :quiet    => { :sleep => 30, :sleep_shift => -5, :duration => 60, :duration_shift => 40 },
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
    log "(music) now playing [#{piece}]"
    `/usr/bin/mpg123-esd #{piece}` if piece and File.exists?(piece)
  end
end
