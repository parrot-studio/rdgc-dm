# coding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

include RDGC::Map

describe RDGC::Map::Direction do

  it "SELF is point itself" do
    Direction::SELF.x.should == 0
    Direction::SELF.y.should == 0

    Direction::SELF.opposite.should equal(Direction::SELF)
  end

  it "UPPER is upper of point" do
    Direction::UPPER.x.should == 0
    Direction::UPPER.y.should == -1

    Direction::UPPER.opposite.should equal(Direction::BOTTOM)
  end

  it "BOTTOM is bottom of point" do
    Direction::BOTTOM.x.should == 0
    Direction::BOTTOM.y.should == 1

    Direction::BOTTOM.opposite.should equal(Direction::UPPER)
  end

  it "LEFT is left of point" do
    Direction::LEFT.x.should == -1
    Direction::LEFT.y.should == 0

    Direction::LEFT.opposite.should equal(Direction::RIGHT)
  end

  it "RIGHT is right of point" do
    Direction::RIGHT.x.should == 1
    Direction::RIGHT.y.should == 0

    Direction::RIGHT.opposite.should equal(Direction::LEFT)
  end

  it "all provides all Direction at clockwise" do
    dirs = [Direction::LEFT, Direction::UPPER, Direction::RIGHT, Direction::BOTTOM]
    Direction.all.should == dirs
  end

  it "each provides each Direction at clockwise" do
    dirs = [Direction::LEFT, Direction::UPPER, Direction::RIGHT, Direction::BOTTOM]

    Direction.each.with_index do |d, i|
      d.should equal(dirs[i])
    end
  end

end
