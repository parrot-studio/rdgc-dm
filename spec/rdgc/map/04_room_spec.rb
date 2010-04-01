# coding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

include RDGC::Map

describe RDGC::Map::Room, "is Area, filled with TileType::ROOM" do

  before(:all) do
    @top = 8
    @bottom = 20
    @left = 21
    @right = 40

    @block = Area.create(@top, @bottom, @left, @right)
    @notblock = Area.create(1, 1, 1, 1)
  end

  it "room_size provides random value for room's height/width" do
    min = 1
    max = 50
    (min..max).each do |val|
      size = Room.room_size(val)
      if size <= 0
        (val-3).should < Util::Config.min_room_size
      else
        size.should >= Util::Config.min_room_size
        size.should <= val-3
      end
    end
  end

  describe "for create_from_block" do

    it "not enough size block can't create room" do
      Room.create_from_block(@notblock).should be_nil
    end

    it "filled with TileType::ROOM" do
      each_create_room do |r|
        r.each_tile do |x, y, t|
          t.should == TileType::ROOM
        end
      end
    end

    it "room height/width <= block height/width - 3" do
      each_create_room do |r|
        r.height.should <= @block.height - 3
        r.width.should <= @block.width - 3
      end
    end

    it "room's all coordinates in block area" do
      each_create_room do |r|
        r.each do |x, y|
          @block.has_xy?(x, y).should be_true
        end
      end
    end

  end

  describe "for create_from_block with min and max value" do

    it "room create accept min and max value" do
      min = 5
      max = 10
      opt = {:min => min, :max => max}

      each_create_room(opt) do |r|
        r.height.should <= max
        r.height.should >= min
        r.width.should <= max
        r.width.should >= min
      end
    end

    it "only max" do
      max = 10
      min = Util::Config.min_room_size
      opt = {:max => max}

      each_create_room(opt) do |r|
        r.height.should <= max
        r.height.should >= min
        r.width.should <= max
        r.width.should >= min
      end
    end

    it "only min" do
      min = 5
      opt = {:min => min}

      each_create_room(opt) do |r|
        r.height.should <= @block.height - 3
        r.height.should >= min
        r.width.should <= @block.width - 3
        r.width.should >= min
      end
    end

    it "min = max if min > max" do
      min = 10
      max = 5
      opt = {:min => min, :max => max}

      each_create_room(opt) do |r|
        r.height.should == max
        r.width.should == max
      end
    end

    it "min value can't under MIN_ROOM_SIZE, and adjust MIN_ROOM_SIZE" do
      min = 1
      opt = {:min => min}

      each_create_room(opt) do |r|
        valid_room?(r).should be_true
      end
    end

    it "room size adjust limit size, if min value over base size" do
      min = 200
      opt = {:min => min}

      each_create_room(opt) do |r|
        r.height.should == @block.height - 3
        r.width.should == @block.width - 3
      end
    end

    it "max value can't over base size, and adjust base size" do
      max = 200
      opt = {:max => max}

      each_create_room(opt) do |r|
        valid_room?(r).should be_true
      end
    end

    it "room size adjust MIN_ROOM_SIZE, if max value under MIN_ROOM_SIZE" do
      max = 1
      opt = {:max => max}

      each_create_room(opt) do |r|
        r.height.should == Util::Config.min_room_size
        r.width.should == Util::Config.min_room_size
      end
    end

  end

  describe "Config affect min_room_size" do

    it "min_room_size change if Config change" do
      Util::Config.set(:min_room_size => 5).should be_true

      min = 1
      max = 50
      (min..max).each do |val|
        size = Room.room_size(val)
        if size <= 0
          (val-3).should < 5
        else
          size.should >= 5
          size.should <= val-3
        end
      end

      Util::Config.reset!.should be_true
    end

  end

  def each_create_room(opt = nil)
    10.times do
      yield(Room.create_from_block(@block, opt))
    end
  end

  def valid_room?(r)
    return false unless r.height <= @block.height - 3
    return false unless r.height >= Util::Config.min_room_size
    return false unless r.width <= @block.width - 3
    return false unless r.width >= Util::Config.min_room_size
    true
  end

end
