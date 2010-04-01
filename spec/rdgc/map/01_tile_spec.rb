# coding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

include RDGC::Map

describe RDGC::Map::Tile do

  it "created for :out" do
    t = Tile.new(:out)
    t.out?.should be_true
    t.movable?.should be_false
  end

  it "created for :wall" do
    t = Tile.new(:wall)
    t.wall?.should be_true
    t.movable?.should be_false
  end

  it "created for :room" do
    t = Tile.new(:room)
    t.room?.should be_true
    t.movable?.should be_true
  end

  it "created for :road" do
    t = Tile.new(:road)
    t.road?.should be_true
    t.movable?.should be_true
  end

  it "TileType::OUT behaves for :out" do
    t = TileType::OUT
    t.out?.should be_true
    t.movable?.should be_false
  end

  it "TileType::WALL behaves for :wall" do
    t = TileType::WALL
    t.wall?.should be_true
    t.movable?.should be_false
  end

  it "TileType::ROOM behaves for :room" do
    t = TileType::ROOM
    t.room?.should be_true
    t.movable?.should be_true
  end

  it "TileType::ROAD behaves for :road" do
    t = TileType::ROAD
    t.road?.should be_true
    t.movable?.should be_true
  end

end
