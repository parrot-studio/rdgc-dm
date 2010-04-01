# coding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

include RDGC::Map

describe RDGC::Map::Area, "provide area, filled with Tile" do

  before(:all) do
    @top = 8
    @bottom = 10
    @left = 11
    @right = 19

    @area = Area.new
    @area.top = @top
    @area.bottom = @bottom
    @area.left = @left
    @area.right = @right
  end

  it "top <= bottom, left <= right" do
    (@top <= @bottom).should be_true
    (@left <= @right).should be_true
  end

  it "#height should be (bottom - top + 1)" do
    @area.height.should == (@bottom - @top + 1)
  end

  it "#width should be (right - left + 1)" do
    @area.width.should == (@right - @left + 1)
  end

  it "#coordinates/#to_co puts params" do
    expect = "t:#{@top} b:#{@bottom} l:#{@left} r:#{@right} / w:#{@area.width} h:#{@area.height}"
    @area.coordinates.should == expect
    @area.to_co.should == expect
  end

  it "#has_xy? should be true if in area, false out of area, for (x, y)" do
    @area.has_xy?(@left, @top).should be_true
    @area.has_xy?(@left-1, @top).should be_false
    @area.has_xy?(@left, @top-1).should be_false
    @area.has_xy?(@right, @bottom).should be_true
    @area.has_xy?(@right+1, @bottom).should be_false
    @area.has_xy?(@right, @bottom+1).should be_false
  end

  it "#each_x provides each left to right" do
    last = nil
    @area.each_x.with_index do |x, i|
      x.should == @left + i
      last = @left + i
    end
    last.should == @right
  end

  it "#each_y provides each top to bottom" do
    last = nil
    @area.each_y.with_index do |y, i|
      y.should == @top + i
      last = @top + i
    end
    last.should == @bottom
  end

  it "#each provides all coordinates" do
    @area.each do |x, y|
      @area.has_xy?(x, y).should be_true
    end

    cs = @area.each
    cs.should be_kind_of(Enumerable)
    cs.each do |x, y|
      @area.has_xy?(x, y).should be_true
    end
  end

  it "#fill_tile set tile for all coordinates" do
    @area.fill_tile(TileType::WALL)
    @area.each do |x, y|
      @area.tile(x, y).should  == TileType::WALL
    end
  end

  it "#each_tile provides each coordinate's tile" do
    @area.fill_tile(TileType::ROAD)
    @area.each_tile do |x, y, t|
      t.should == TileType::ROAD
    end

    ts = @area.each_tile
    ts.should be_kind_of(Enumerable)
    tiles = ts.to_a.map{|a| a.last}
    tiles.all?{|t| t == TileType::ROAD}
  end

  it "#set_tile will set tile object for (x, y)" do
    @area.set_tile(@left, @top, TileType::ROOM).should be_an_instance_of(Tile)
    t = @area.tile(@left, @top)
    t.should be_an_instance_of(Tile)
    t.should == TileType::ROOM
  end

  it "#set_tile failed, and #tile is nil, if out of area" do
    @area.set_tile(@left-1, @top-1, TileType::ROOM).should be_nil
    t = @area.tile(@left-1, @top-1)
    t.should be_nil
  end

  it "#random_point provides random point in area" do
    10.times do
      x, y = @area.random_point
      @area.has_xy?(x, y).should be_true
    end
  end

end
