# coding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

include RDGC::Map
include RDGC::Maker

describe RDGC::Maker::TempBlock, 'is temp Block for Dungeon make' do

  it "create_whole_block will create from width/height" do
    tb = TempBlock.create_whole_block(20, 30)
    tb.should be_an_instance_of(TempBlock)
    tb.width.should == 20
    tb.height.should == 30
    tb.top.should == 0
    tb.bottom.should == 29
    tb.left.should == 0
    tb.right.should == 19
  end

  it "#create_pure_block provides a pure Block instance from self" do
    tb = TempBlock.create(0, 20, 0, 20)

    room = Room.create(5, 15, 5, 15)
    road1 = Road.create(0, 4, 10, 10)
    road2 = Road.create(16, 20, 12, 12)

    tb.room = room
    tb.roads << road1
    tb.roads << road2

    b = tb.create_pure_block
    b.should be_an_instance_of(Block)
    b.should_not be_an_instance_of(TempBlock)
    b.room.should == room
    b.roads.should be_include(road1)
    b.roads.should be_include(road2)
  end

  it "#create_pure_block will return nil, if has no room and no road" do
    tb = TempBlock.create_whole_block(20, 20)
    tb.should be_an_instance_of(TempBlock)
    tb.create_pure_block.should be_nil
  end

end
