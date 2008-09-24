require 'tempfile'
class Thermometer
  attr_reader :lower_limit, :upper_limit, :last

  def initialize(args={})
    temp = args[:temperature] ? args[:temperature] : nil
    @lower_limit = (args[:lower_limit] ? args[:lower_limit] : 0).to_f
    @upper_limit = (args[:upper_limit] ? args[:upper_limit] : 100).to_f

    raise ArgumentError, "initial temperature [#{temp}] should not exceed upper limit [#{upper_limit}]" if temp and temp > upper_limit
    raise ArgumentError, "initial temperature [#{temp}] should not fall below lower limit [#{upper_limit}]" if temp and temp < lower_limit
    raise ArgumentError, "lower limit should not meet or exceed upper limit" unless upper_limit > lower_limit

    @temperature = (temp ? temp : lower_limit).to_f
    @last = Time.now
  end

  def activity(amount)
    @temperature = self.temperature + amount.to_f
    constrain
    log "activity called with [#{amount}], temperature now [#{@temperature}]" if $DEBUG
  end

  def temperature
    cool
    log "temperature called returning [#{@temperature}]" if $DEBUG
    @temperature
  end

private

  
  def log(message)
    puts "#{Time.now.to_i} #{__FILE__} #{message}"
  end

  def range
    self.upper_limit - self.lower_limit
  end

  def constrain
    @temperature = self.upper_limit if @temperature > self.upper_limit
    @temperature = self.lower_limit if @temperature < self.lower_limit
  end

  def cool
    @temperature = self.lower_limit.to_f + (@temperature - self.lower_limit.to_f) * Math.exp(-1*elapsed_time.to_f/295)
    @last = Time.now
  end

  def elapsed_time
    Time.now - self.last
  end
end

STDOUT.sync = true
