require File.dirname(__FILE__) + '/spec_helper'
require 'thermometer'

describe Thermometer, "when creating" do
  it "should have a lower limit of 0 by default" do
    Thermometer.new.lower_limit.should == 0
  end

  it "should have an upper limit of 100 by default" do
    Thermometer.new.upper_limit.should == 100
  end

  it "should have temperature at lower limit by default" do
    thermometer = Thermometer.new
    thermometer.temperature.should == thermometer.lower_limit
  end

  it "should allow setting initial temperature" do
    Thermometer.new(:temperature => 20).temperature.should be_close(20, 0.01)
  end

  it "should allow setting lower limit" do
    thermometer = Thermometer.new(:lower_limit => -10).lower_limit.should == -10
  end
    
  it "should allow setting upper limit" do
    thermometer = Thermometer.new(:upper_limit => 10).upper_limit.should == 10
  end

  it "should allow specifying only some parameters" do
    thermometer = Thermometer.new(:upper_limit => 200).upper_limit.should == 200
  end

  it "should not allow an initial temperature less than the lower limit" do
    lambda { Thermometer.new(:temperature => -100) }.should raise_error(ArgumentError)
    lambda { Thermometer.new(:temperature => -100, :lower_limit => -10) }.should raise_error(ArgumentError)
  end

  it "should not allow an initial temperature greater than the upper limit" do
    lambda { Thermometer.new(:temperature => 200) }.should raise_error(ArgumentError)
    lambda { Thermometer.new(:temperature => 200, :upper_limit => 199) }.should raise_error(ArgumentError)
  end

  it "should not allow lower limit to be greater than or equal to the upper limit" do
    lambda { Thermometer.new(:temperature => 100, :lower_limit => 100, :upper_limit => 100) }.should raise_error(ArgumentError)
    lambda { Thermometer.new(:temperature => 100, :lower_limit => 100, :upper_limit => 99) }.should raise_error(ArgumentError)
    lambda { Thermometer.new(:temperature => 100, :lower_limit => 100) }.should raise_error(ArgumentError)
    lambda { Thermometer.new(:temperature => 100, :lower_limit => 101) }.should raise_error(ArgumentError)
    lambda { Thermometer.new(:temperature => 101, :lower_limit => 101) }.should raise_error(ArgumentError)
  end

  it "should have a very recent last activity time" do
    t = Time.now
    (Thermometer.new.last - t).should be <= 1
  end
end

describe Thermometer, "at lower limit" do
  before(:each) do
    @thermometer = Thermometer.new(:temperature => -10, :lower_limit => -10)
  end

  it "should maintain a temperature at the lower limit when negative activity is measured" do
    @thermometer.activity(-1)
    @thermometer.temperature.should == @thermometer.lower_limit
  end

  it "should maintain a temperature at the lower limit when no activity is measured" do
    @thermometer.activity(0)
    @thermometer.temperature.should == @thermometer.lower_limit
  end

  it "should raise temperature when positive activity is measured" do
    @thermometer.activity(1)
    @thermometer.temperature.should be > @thermometer.lower_limit
  end
end

describe Thermometer, "at some moderate temperature" do
  before(:each) do
    @thermometer = Thermometer.new(:temperature => 50, :lower_limit => -100, :upper_limit => 100)
  end

  it "should decrease temperature when negative activity is encountered" do
    @thermometer.activity(-1)
    @thermometer.temperature.should be < 50
  end

  it "should not raise temperature when no activity is registered" do
    @thermometer.activity(0)
    @thermometer.temperature.should_not be > 50
  end

  it "should increase temperature when positive activity is encountered" do
    @thermometer.activity(1)
    @thermometer.temperature.should be > 50
  end

  it "should not drop below lower limit when massive negative activity is encountered" do
    @thermometer.activity(-10000000000)
    @thermometer.temperature.should_not be < @thermometer.lower_limit
  end

  it "should not exceed upper limit when massive positive activity is encountered" do
    @thermometer.activity(10000000000)
    @thermometer.temperature.should_not be > @thermometer.upper_limit
  end
end

describe Thermometer, "at upper limit" do
  before(:each) do
    @thermometer = Thermometer.new(:temperature => 100, :lower_limit => -100, :upper_limit => 100)
  end

  it "should lower temperature when negative activity is measured" do
    @thermometer.activity(-1)
    @thermometer.temperature.should be < @thermometer.upper_limit
  end

  it "should not raise temperature past upper limit when no actity is measured" do 
    @thermometer.activity(0)
    @thermometer.temperature.should_not be > @thermometer.upper_limit
  end

  it "should not raise temperature past upper limit when positive activity is measured" do
    @thermometer.activity(1)
    @thermometer.temperature.should_not be > @thermometer.upper_limit
  end
end

describe Thermometer, "in general" do
  before(:each) do
    @time = Time.now
    @thermometer = Thermometer.new(:temperature => 50)
  end

  it "should record the time when activity happened" do
    Time.expects(:now).at_least_once.returns(@time + 60)
    @thermometer.activity(0)
    @thermometer.last.should == (@time + 60)
  end
    
  it "should register a cooling when no activity has passed" do
    Time.expects(:now).at_least_once.returns(@time + 60)
    @thermometer.activity(0)
    @thermometer.temperature.should be < 50.0
  end

  it "should cool faster at higher temperatures than at lower temperatures" do
    high = Thermometer.new(:temperature => 100)
    low = Thermometer.new(:temperature => 50)
    Time.expects(:now).at_least_once.returns(@time + 60)
    high.activity(0)
    low.activity(0)
    (100 - high.temperature).should be > (50 - low.temperature)
  end

  it "should cool at a rate proportional to the temperature scale (lower limit to upper limit)" do
    big_scale = Thermometer.new(:temperature => 1000, :lower_limit => 0, :upper_limit => 1000)
    little_scale = Thermometer.new(:temperature => 10, :lower_limit => 0, :upper_limit => 10)
    Time.expects(:now).at_least_once.returns(@time + 60)
    big_scale.activity(0)
    little_scale.activity(0)
    (1000-big_scale.temperature).should be_close(100.0 * (10.0-little_scale.temperature), 0.03)
  end

  it "should cool down to almost lower limit in 20 minutes" do
    Time.expects(:now).at_least_once.returns(@time + 1200)
    @thermometer.activity(0)
    @thermometer.temperature.should be < (@thermometer.lower_limit + 1)
  end

  it "should not cool down to lower limit in less than 17 minutes" do
    Time.expects(:now).at_least_once.returns(@time + 1020)
    @thermometer.activity(0)
    @thermometer.temperature.should_not be < (@thermometer.lower_limit + 1.5)
  end
end
