class Media
  def initialize(thermometer)
    @buckets ||= []
    @params ||= []
    @lower = thermometer.lower_limit
    @range = thermometer.upper_limit - @lower
    raise "Must have at least one defined bucket" if @buckets.empty?
    @bucket_size = @range/@buckets.size.to_f
  end

  def play(temperature)
    perform(find_bucket(temperature))
  end

  def find_bucket(temperature)
    num = ((temperature-@lower) / @bucket_size).to_i
    num = @buckets.size - 1 if num >= @buckets.size
    @buckets[num]
  end

  def perform(bucket)
    params = @params[bucket]
    duration = rand(params[:duration]) + params[:duration_shift]
    duration = 0 if duration < 0
    sleep_time = rand(params[:sleep]) + params[:sleep_shift]
    sleep_time = 0 if sleep_time < 0
    log "(#{self.class.name}) playing from bucket [#{bucket}] [#{@buckets.inspect}] for [#{duration}]"
    start_time = Time.now
    contents = media(bucket)
    piece = contents[rand(contents.size)]
    while Time.now - start_time < duration
      play_single(piece)
      sleep sleep_time
    end
    sleep 1
  end

  def media(bucket)
    raise "Unimplemented for class (#{self.class.name})!"
  end

  def play_single(piece)
    raise "Unimplemented for class (#{self.class.name})!"
  end
end

Dir[File.dirname(__FILE__)+'/media_*.rb'].each {|f| require f }
