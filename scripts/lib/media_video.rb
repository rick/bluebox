require 'tempfile'

class Video < Media
  def initialize(thermometer)
    @buckets = [:blank, :camera, :normal, :normal, :normal, :artsy, :artsy]
  
    @params = {
      :blank    => { :sleep => 15,  :sleep_shift =>  0, :duration => 45,  :duration_shift =>  0 },
      :artsy    => { :sleep => 10,  :sleep_shift =>  0, :duration => 90,  :duration_shift =>  0 },
      :normal   => { :sleep => 10,  :sleep_shift =>  0, :duration => 90,  :duration_shift =>  0 },
      :camera   => { :sleep =>  5,  :sleep_shift =>  0, :duration => 30,  :duration_shift =>  0 }
    }
    super
  end

  def media(bucket)
    @duration = @params[bucket][:duration]
    Dir["/art/movies/#{bucket}/*"]
  end

  def play_single(piece)
    ml = movie_length(piece)
    start = random_offset(piece, @duration) 
    log "(movies) now playing [#{piece}] for [#{@duration}] (/bin/sh -x /art/scripts/play_movie.sh #{piece} #{start} #{(@duration > ml) ? (ml + 1) : @duration})"
    `/bin/sh -x /art/scripts/play_movie.sh #{piece} #{start} #{@duration}` if piece and File.exists?(piece)
  end

  def random_offset(movie, duration)
    ml = movie_length(movie)
    rand(ml.to_f - duration.to_f)
  end

  def movie_length(movie)
    ml = `/bin/sh /art/scripts/get_movie_length.sh #{movie} | tail -1`.chomp.to_i
    log "found length of movie [#{movie}] -> #{ml} seconds"
    ml
  end
end
