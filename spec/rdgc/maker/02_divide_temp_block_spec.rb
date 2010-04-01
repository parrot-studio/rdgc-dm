# coding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

include RDGC::Map
include RDGC::Maker

describe RDGC::Maker::DivideTempBlock, 'is TempBlock for divide maker' do

  describe 'block divide' do

    it "#depth default is 0" do
      dtb =DivideTempBlock.create(0, 10, 0, 10)
      dtb.depth.should == 0
      dtb.depth = 3
      dtb.depth.should == 3
    end

    it "#min_size default is config value, and #min_divide_size provides twice value" do
      dtb =DivideTempBlock.create(0, 10, 0, 10)
      dtb.min_size.should == Util::Config.min_block_size
      dtb.min_divide_size.should == Util::Config.min_block_size * 2

      dtb.min_size = 1
      dtb.min_size.should == Util::Config.min_block_size
      dtb.min_divide_size.should == Util::Config.min_block_size * 2

      val = Util::Config.min_block_size + 2
      dtb.min_size = val
      dtb.min_size.should == val
      dtb.min_divide_size.should == val * 2
    end

    it "#opposite_direction provides opposite of divide_direction" do
      dtb =DivideTempBlock.create_whole_block(20, 20)
      dtb.opposite_direction.should be_nil
      dtb.divide_direction = :vertical
      dtb.opposite_direction.should == :horizontal
      dtb.divide_direction = :horizontal
      dtb.opposite_direction.should == :vertical
    end

    it "#dividable_size? check self can devidable for divide_direction" do
      dtb_h = DivideTempBlock.create_whole_block(5, 30)
      dtb_h.dividable_size?.should be_false
      dtb_h.divide_direction = :vertical
      dtb_h.dividable_size?.should be_false
      dtb_h.divide_direction = :horizontal
      dtb_h.dividable_size?.should be_true

      dtb_w = DivideTempBlock.create_whole_block(30, 5)
      dtb_w.dividable_size?.should be_false
      dtb_w.divide_direction = :vertical
      dtb_w.dividable_size?.should be_true
      dtb_w.divide_direction = :horizontal
      dtb_w.dividable_size?.should be_false
    end

    it "#set_dividable will set dividable, but reject if enough size" do
      dtb =DivideTempBlock.create_whole_block(20, 20)
      dtb.divide_direction = :vertical
      dtb.dividable_size?.should be_true

      dtb.dividable?.should be_false
      dtb.set_dividable
      dtb.dividable?.should be_true

      dtb.dividable(false)
      dtb.min_size = 99
      dtb.dividable_size?.should be_false

      dtb.dividable?.should be_false
      dtb.set_dividable
      dtb.dividable?.should be_false

      dtb.dividable
      dtb.dividable?.should be_true
    end

    it "#divide_point provides random value for divide" do
      dtb =DivideTempBlock.create_whole_block(30, 40)
      dtb.min_size = 5

      10.times do
        wval = dtb.divide_point(dtb.width)
        wval.should >= dtb.min_size
        wval.should <= (dtb.width - dtb.min_divide_size)

        wval = dtb.divide_point(dtb.height)
        wval.should >= dtb.min_size
        wval.should <= (dtb.height - dtb.min_divide_size)
      end
    end

    it "#divide provides new twice blocks, seted opposite direction" do
      10.times do
        dtb =DivideTempBlock.create_whole_block(40, 40)
        dtb.divide_direction = :vertical

        ret = dtb.divide
        ret.should_not be_empty
        ret.size.should <= 2

        ret.each do |b|
          b.width.should < dtb.width
          b.height == dtb.height
          b.divide_direction.should == :horizontal
        end

        dtb =DivideTempBlock.create_whole_block(40, 40)
        dtb.divide_direction = :horizontal

        ret = dtb.divide
        ret.should_not be_empty
        ret.size.should <= 2

        ret.each do |b|
          b.width.should == dtb.width
          b.height < dtb.height
          b.divide_direction.should == :vertical
        end
      end
    end

    it "#divide will returen nil, if not enough size" do
      dtb =DivideTempBlock.create_whole_block(5, 40)
      dtb.divide_direction = :vertical
      dtb.divide.should be_nil
    end

  end

  describe 'for road create' do

    before(:each) do
      @dtb =DivideTempBlock.create_whole_block(40, 40)
    end

    it "#road_created is sign for main road created" do
      @dtb.road_created?.should be_false
      @dtb.road_created
      @dtb.road_created?.should be_true
    end

    it "#road_point is created road's coordinate for each four direction" do
      params = {
        :top => 1,
        :bottom => 2,
        :left => 3,
        :right => 4
      }

      @dtb.road_point.should be_empty

      params.each do |d, v|
        @dtb.set_road_point(d, v)
      end

      params.each do |d, v|
        @dtb.road_point[d].should == v
      end
    end

    it "#remain_cling_blocks is cling block, not have room, and not connect by road from self" do
      @dtb.remain_cling_blocks.should be_empty
      @dtb.has_remain_cling_blocks?.should be_false

      b = DivideTempBlock.create_whole_block(10, 10)
      room = Room.create(1, 5, 1, 5)
      b.room = room

      @dtb.add_remain_cling_blocks(b)
      @dtb.remain_cling_blocks.should be_empty
      @dtb.has_remain_cling_blocks?.should be_false

      b = DivideTempBlock.create_whole_block(10, 10)

      @dtb.add_remain_cling_blocks(b)
      @dtb.remain_cling_blocks.size.should == 1
      @dtb.remain_cling_blocks.first.should == b
      @dtb.has_remain_cling_blocks?.should be_true
    end

    it "#dead_end is only one road block of cross point" do
      @dtb.dead_end?.should be_false

      @dtb.create_room
      @dtb.dead_end?.should be_false
      @dtb.remove_all

      @dtb.create_cross_point
      @dtb.dead_end?.should be_false

      @dtb.set_road_point(:top, 1)
      @dtb.dead_end?.should be_true

      @dtb.set_road_point(:bottom, 20)
      @dtb.dead_end?.should be_false
    end

    it "#remain_direction provieds remain direction of not road create" do
      @dtb.remain_direction.size.should == 4

      @dtb.set_road_point(:top, 1)
      @dtb.remain_direction.size.should == 3
      @dtb.remain_direction.should_not be_include(:top)

      @dtb.set_road_point(:bottom, 20)
      @dtb.remain_direction.size.should == 2
      @dtb.remain_direction.should_not be_include(:top)
      @dtb.remain_direction.should_not be_include(:bottom)
    end

    it "create_road to cling block" do
      b1 = DivideTempBlock.create(1, 10, 1, 10)
      b2 = DivideTempBlock.create(11, 20, 1, 10)
      b3 = DivideTempBlock.create(1, 10 , 11, 20)
      b4 = DivideTempBlock.create(11, 20 , 11, 20)

      b1.create_room
      b2.create_cross_point
      b3.create_cross_point
      b4.create_room

      b1.create_road_to(b2)
      b1.roads.size.should == 2
      b2.roads.size.should == 1

      b2.create_road_to(b4)
      b2.roads.size.should == 3
      b4.roads.size.should == 1

      b4.create_road_to(b3)
      b4.roads.size.should == 2
      b3.roads.size.should == 2

      b3.dead_end?.should be_true
    end

  end

end
