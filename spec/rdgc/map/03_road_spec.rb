# coding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

include RDGC::Map

describe RDGC::Map::Road, "is Area, filled with TileType::ROAD" do

  before do
    @top = 8
    @bottom = 8
    @left = 11
    @right = 19

    @road = Road.create(@top, @bottom, @left, @right)
  end

  it "filled with TileType::ROAD" do
    @road.each_tile do |x, y, t|
      t.should == TileType::ROAD
    end
  end

end
