# coding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

include RDGC::Map

describe RDGC::Map::Block, 'has room and roads' do

  before do
    @block = Block.create(1, 20, 11, 30)
  end

  it "set/remove room" do
    room = Room.create(1, 7, 15, 20)

    @block.room = room
    @block.has_room?.should be_true
    @block.room.should equal(room)

    @block.remove_room
    @block.has_room?.should be_false
    @block.room.should be_nil
  end

  it "add/remove road" do
    road1 = Road.create(2, 2, 11, 14)
    road2 = Road.create(1, 6, 20, 20)

    @block.add_road(road1)
    @block.has_road?.should be_true
    @block.roads.size.should == 1
    @block.roads[0].should equal(road1)

    @block.add_road(road2)
    @block.has_road?.should be_true
    @block.roads.size.should == 2
    @block.roads[0].should equal(road1)
    @block.roads[1].should equal(road2)

    @block.remove_roads
    @block.has_road?.should be_false
    @block.roads.should be_empty
  end

  it "#fill_room will set tile at room coordinates" do
    room = Room.create(1, 7, 15, 20)

    @block.room = room
    @block.has_room?.should be_true
    @block.room.should equal(room)

    @block.fill_room

    room.each_tile do |x, y, t|
      @block.has_xy?(x, y).should be_true
      @block.tile(x, y).should equal(TileType::ROOM)
    end
  end

  it "#fill_roads will set tile at road coordinates" do
    road1 = Road.create(2, 2, 11, 14)
    road2 = Road.create(1, 6, 20, 20)

    @block.add_road(road1)
    @block.add_road(road2)
    @block.has_road?.should be_true
    @block.roads.size.should == 2

    @block.fill_roads

    [road1, road2].each do |road|
      road.each_tile do |x, y, t|
        @block.has_xy?(x, y).should be_true
        @block.tile(x, y).should equal(TileType::ROAD)
      end
    end
  end

  it "#fill will fill room/road, and fill at wall other coordinates" do
    room = Room.create(1, 7, 15, 20)
    road = Road.create(2, 2, 11, 14)

    @block.room = room
    @block.add_road(road)

    @block.fill

    @block.each_tile do |x, y, t|
      case
      when room.has_xy?(x, y)
        t.should equal(TileType::ROOM)
      when road.has_xy?(x, y)
        t.should equal(TileType::ROAD)
      else
        t.should equal(TileType::WALL)
      end
    end
  end

  it "#create_room create and set room from self block" do
    @block.room.should be_nil

    10.times do
      room = @block.create_room
      room.should be_an_instance_of(Room)

      room.width.should <= @block.width - 3
      room.height.should <= @block.height - 3

      room.each do |x, y|
        @block.has_xy?(x, y).should be_true
      end
    end
  end

  it "#create_room accept option value" do
    min = 5
    max = 8

    @block.room.should be_nil
    10.times do
      room = @block.create_room(:min => min, :max => max)
      room.should be_an_instance_of(Room)

      room.width.should >= min
      room.width.should <= max
      room.height.should >= min
      room.height.should <= max
    end
  end

  it "cross_point is cross point of road, instead of room" do
    @block.cross_point.should be_nil
    @block.has_cross_point?.should be_false

    10.times do
      x, y =  @block.create_cross_point

      @block.has_cross_point?.should be_true
      @block.has_xy?(x, y).should be_true
      x.should >= @block.left + 1
      x.should <= @block.right - 2
      y.should >= @block.top + 1
      y.should <= @block.bottom - 2

      _x, _y = @block.cross_point
      _x.should == x
      _y.should == y
    end

    @block.remove_cross_point

    @block.cross_point.should be_nil
    @block.has_cross_point?.should be_false
  end

  it "#remove_all will clear room/road/cross_point and #empty? is true" do
    room = Room.create(1, 7, 15, 20)
    road = Road.create(2, 2, 11, 14)

    @block.room = room
    @block.add_road(road)
    @block.create_cross_point

    @block.has_room?.should be_true
    @block.has_road?.should be_true
    @block.has_cross_point?.should be_true
    @block.empty?.should be_false

    @block.remove_all

    @block.has_room?.should be_false
    @block.has_road?.should be_false
    @block.has_cross_point?.should be_false
    @block.empty?.should be_true
  end

  it "#cling_to_top? / #cling_direction_to judge self and target block adjoin with top" do
    # 基準（元の左上）
    b = Block.create(-10, 0, 0, 10)
    @block.cling_to_top?(b).should be_false

    # 右端が範囲内
    b = Block.create(-10, 0, 1, 11)
    @block.cling_to_top?(b).should be_true
    @block.cling_direction_to(b).should == :top

    # 左端が範囲内
    b = Block.create(-10, 0, 30, 40)
    @block.cling_to_top?(b).should be_true
    @block.cling_direction_to(b).should == :top

    # 左端が範囲外
    b = Block.create(-10, 0, 31, 41)
    @block.cling_to_top?(b).should be_false

    # 重なるとダメ
    b = Block.create(-9, 1, 15, 25)
    @block.cling_to_top?(b).should be_false
  end

  it "#cling_to_bottom? / #cling_direction_to judge self and target block adjoin with bottom" do
    # 基準（元の左下）
    b = Block.create(21, 31, 0, 10)
    @block.cling_to_bottom?(b).should be_false

    # 右端が範囲内
    b = Block.create(21, 31, 1, 11)
    @block.cling_to_bottom?(b).should be_true
    @block.cling_direction_to(b).should == :bottom

    # 左端が範囲内
    b = Block.create(21, 31, 30, 40)
    @block.cling_to_bottom?(b).should be_true
    @block.cling_direction_to(b).should == :bottom

    # 左端が範囲外
    b = Block.create(21, 31, 31, 41)
    @block.cling_to_bottom?(b).should be_false

    # 重なるとダメ
    b = Block.create(20, 30, 15, 25)
    @block.cling_to_bottom?(b).should be_false
  end

  it "#cling_to_left? / #cling_direction_to judge self and target block adjoin with left" do
    # 基準（元の左上）
    b = Block.create(-10, 0, 0, 10)
    @block.cling_to_left?(b).should be_false

    # 下端が範囲内
    b = Block.create(-9, 1, 0, 10)
    @block.cling_to_left?(b).should be_true
    @block.cling_direction_to(b).should == :left

    # 上端が範囲内
    b = Block.create(20, 30, 0, 10)
    @block.cling_to_left?(b).should be_true
    @block.cling_direction_to(b).should == :left

    # 上端が範囲外
    b = Block.create(21, 31, 0, 10)
    @block.cling_to_left?(b).should be_false

    # 重なるとダメ
    b = Block.create(15, 30, 1, 11)
    @block.cling_to_left?(b).should be_false
  end

  it "#cling_to_right? / #cling_direction_to judge self and target block adjoin with right" do
    # 基準（元の右上）
    b = Block.create(-10, 0, 31, 41)
    @block.cling_to_right?(b).should be_false

    # 下端が範囲内
    b = Block.create(-9, 1, 31, 41)
    @block.cling_to_right?(b).should be_true
    @block.cling_direction_to(b).should == :right

    # 上端が範囲内
    b = Block.create(20, 30, 31, 41)
    @block.cling_to_right?(b).should be_true
    @block.cling_direction_to(b).should == :right

    # 上端が範囲外
    b = Block.create(21, 31, 31, 41)
    @block.cling_to_right?(b).should be_false

    # 重なるとダメ
    b = Block.create(15, 30, 30, 40)
    @block.cling_to_right?(b).should be_false
  end

end
