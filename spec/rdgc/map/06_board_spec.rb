# coding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

include RDGC::Map

describe RDGC::Map::Board, 'has rooms and roads from Blocks' do

  it "#set_coordinates will set self coordinates from blocks coordinates" do
    b = Board.create(1, 1, 1, 1)
    b.should be_an_instance_of(Board)
    b.width.should == 1
    b.height.should == 1

    b.blocks << Block.create(0, 20, 10, 30)
    b.blocks << Block.create(10, 30, 20, 40)

    b.set_coordinates

    b.top.should == 0
    b.bottom.should == 30
    b.left.should == 10
    b.right.should == 40
  end

  it "#areas provides rooms and roads list" do
    b = Board.create(0, 20, 0, 20)

    room = Room.create(5, 15, 5, 15)
    road1 = Road.create(0, 4, 10, 10)
    road2 = Road.create(16, 20, 12, 12)

    b.rooms << room
    b.roads << road1
    b.roads << road2

    b.areas.each do |a|
      [room, road1, road2].should be_include(a)
    end
  end

  it "#areas_for provide rooms/roads list at (x, y)" do
    b = Board.create(0, 20, 0, 20)

    room = Room.create(5, 15, 5, 15)
    road1 = Road.create(0, 4, 10, 10)
    road2 = Road.create(16, 20, 12, 12)

    b.rooms << room
    b.roads << road1
    b.roads << road2

    b.areas_for(10, 10).should be_include(room)
    b.areas_for(10, 2).should be_include(road1)
    b.areas_for(12, 20).should be_include(road2)
  end

  it "#fill will fill room/road, and fill at wall other coordinates" do
    b = Board.create(0, 20, 0, 20)

    room = Room.create(5, 15, 5, 15)
    road1 = Road.create(0, 4, 10, 10)
    road2 = Road.create(16, 20, 12, 12)

    b.rooms << room
    b.roads << road1
    b.roads << road2

    b.fill

    b.each_tile do |x, y, t|
      case t
      when TileType::WALL
        room.has_xy?(x, y).should be_false
        road1.has_xy?(x, y).should be_false
        road2.has_xy?(x, y).should be_false

        b.movable?(x, y).should be_false
        b.room?(x, y).should be_false
        b.road?(x, y).should be_false
      when TileType::ROOM
        room.has_xy?(x, y).should be_true
        road1.has_xy?(x, y).should be_false
        road2.has_xy?(x, y).should be_false

        b.movable?(x, y).should be_true
        b.room?(x, y).should be_true
        b.road?(x, y).should be_false
      when TileType::ROAD
        room.has_xy?(x, y).should be_false
        [road1, road2].map{|r| r.has_xy?(x, y)}.any?.should be_true

        b.movable?(x, y).should be_true
        b.room?(x, y).should be_false
        b.road?(x, y).should be_true
      end
    end
  end

  it "#init will initialize self from blocks, and create_from_blocks will provides init Board" do
    block1 = Block.create(0, 20, 0, 20)
    room1 = Room.create(5, 15, 5, 15)
    road1 = Road.create(0, 4, 10, 10)
    road2 = Road.create(16, 20, 12, 12)
    block1.room = room1
    block1.add_road(road1)
    block1.add_road(road2)

    block2 = Block.create(21, 40, 0, 20)
    room2 = Room.create(25, 35, 25, 35)
    road3 = Road.create(21, 24, 12, 12)
    block2.room = room2
    block2.add_road(road3)

    b1 = Board.create(1, 1, 1, 1)
    b1.init([block1, block2])

    b2 = Board.create_from_blocks([block1, block2])
    b2.should be_an_instance_of(Board)

    [b1, b2].each do |b|
      b.blocks.should be_include(block1)
      b.blocks.should be_include(block2)
      b.rooms.should be_include(room1)
      b.rooms.should be_include(room2)
      b.roads.should be_include(road1)
      b.roads.should be_include(road2)
      b.roads.should be_include(road3)

      # set_coordinates
      b.top.should == 0
      b.bottom.should == 40
      b.left.should == 0
      b.right.should == 20

      # fill
      b.each_tile do |x, y, t|
        case t
        when TileType::WALL
          [room1, room2].map{|r| r.has_xy?(x, y)}.any?.should be_false
          [road1, road2, road3].map{|r| r.has_xy?(x, y)}.any?.should be_false

          b.movable?(x, y).should be_false
          b.room?(x, y).should be_false
          b.road?(x, y).should be_false
        when TileType::ROOM
          [room1, room2].map{|r| r.has_xy?(x, y)}.any?.should be_true
          [road1, road2, road3].map{|r| r.has_xy?(x, y)}.any?.should be_false

          b.movable?(x, y).should be_true
          b.room?(x, y).should be_true
          b.road?(x, y).should be_false
        when TileType::ROAD
          [room1, room2].map{|r| r.has_xy?(x, y)}.any?.should be_false
          [road1, road2, road3].map{|r| r.has_xy?(x, y)}.any?.should be_true

          b.movable?(x, y).should be_true
          b.room?(x, y).should be_false
          b.road?(x, y).should be_true
        end
      end
    end
  end

end