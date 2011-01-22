# coding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

include RDGC::Map
include RDGC::Maker

describe RDGC::Maker::DivideDungeonMaker, 'create room/road for each block' do

  describe "create room" do

    it "create_room by default" do
      10.times do
        maker = create_maker_with_blocks
        maker.create_room

        maker.blocks.each do |b|
          rsl_room = b.has_room?
          rsl_cross = b.has_cross_point?
          (rsl_room || rsl_cross).should be_true
          (rsl_room && rsl_cross).should be_false
        end

        maker.blocks.select{|b| b.has_room?}.size.should >= 2
      end
    end

    it "min_room_size/max_room_size affect room size" do
      val = 5

      10.times do
        maker = create_maker_with_blocks(:min_room_size => val)
        maker.create_room

        maker.blocks.select{|b| b.has_room?}.map{|b| b.room}.each do |r|
          r.width.should >= val
          r.height.should >= val
        end
      end

      10.times do
        maker = create_maker_with_blocks(:max_room_size => val)
        maker.create_room

        maker.blocks.select{|b| b.has_room?}.map{|b| b.room}.each do |r|
          r.width.should <= val
          r.height.should <= val
        end
      end
    end

    it "min_room_count/max_room_count affect room count" do
      10.times do
        maker = create_maker_with_blocks(:min_room_count => 3)
        maker.create_room
        maker.blocks.select{|b| b.has_room?}.size.should >= 3
      end

      10.times do
        maker = create_maker_with_blocks(:max_room_count => 3)
        maker.create_room
        maker.blocks.select{|b| b.has_room?}.size.should <= 3
      end

      # min_room_count = 1でも2部屋できる (from ver2.2)
      10.times do
        maker = create_maker_with_blocks(:min_room_count => 1, :max_room_count => 1)
        maker.create_room
        maker.blocks.select{|b| b.has_room?}.size.should == 2
      end

    end

    it "cross_road_ratio affect room create" do
      10.times do
        maker = create_maker_with_blocks(:cross_road_ratio => 9)
        maker.create_room

        all_size = maker.blocks.size
        maker.blocks.select{|b| b.has_room?}.size.should >= 2
        maker.blocks.select{|b| b.has_cross_point?}.size.should <= all_size - 2
      end

      10.times do
        maker = create_maker_with_blocks(:cross_road_ratio => 0)
        maker.create_room

        all_size = maker.blocks.size
        maker.blocks.select{|b| b.has_room?}.size.should == all_size
        maker.blocks.select{|b| b.has_cross_point?}.size.should == 0
      end
    end

    it "fixed count rooms create, if force_room_count exists" do
      # force_room_countを指定すれば、1部屋や部屋なしも作れる
      (0..2).each do |force_size|
        10.times do
          maker = create_maker_with_blocks(:force_room_count => force_size)
          maker.create_room

          max = maker.blocks.size
          expect = (max > force_size ? force_size : max)
          maker.blocks.select{|b| b.has_room?}.size.should == expect
        end
      end
    end

  end

  describe "create road" do

    it "room block should has roads, if min_room_count too big" do
      10.times do
        maker = create_maker_with_blocks(:min_room_count => 99)
        maker.create_room
        maker.create_road

        maker.blocks.select{|b| b.has_room?}.each do |b|
          b.has_road?.should be_true
        end
      end
    end

    it "no create road if only one block" do
      maker = create_maker_with_blocks(:min_block_size => 99)
      maker.create_room
      maker.blocks.size.should == 1

      maker.create_road
      maker.blocks.select{|b| b.has_road?}.should be_empty
    end

    it "#move_room_and_connect spec" do

      b1 = DivideTempBlock.create(0, 10, 0, 10)
      b2 = DivideTempBlock.create(0, 10, 11, 20)
      b3 = DivideTempBlock.create(0, 10, 21, 30)
      b4 = DivideTempBlock.create(0, 10, 31, 40)

      b1.create_room
      b2.create_room
      b4.create_room
      b1.create_road_to(b2)
      b2.add_remain_cling_blocks(b3)

      maker = DivideDungeonMaker.new
      maker.instance_eval do
        @params = {:min_room_count => 10}
        @blocks = [b1, b2, b3, b4]
      end

      maker.move_room_and_connect

      b3.has_room?.should be_true
      b3.has_road?.should be_true
      b4.has_room?.should be_false
      b4.has_road?.should be_false
    end

  end

  describe "make all" do

    it "create provide complete board" do
      board = DivideDungeonMaker.create(40, 40)
      board.should be_an_instance_of(Map::Board)
      board.blocks.select{|b| b.has_room?}.each do |b|
        b.should be_an_instance_of(Block)
        b.should_not be_an_instance_of(DivideTempBlock)
        b.has_road?.should be_true
      end
    end

    it "create accept params" do
      params = {}
      params[:min_room_size] = 5
      params[:max_room_size] = 10
      params[:min_block_size] = 4
      params[:min_block_size] = 8
      params[:min_room_count] = 3
      params[:max_room_count] = 8
      params[:max_depth] = 4
      params[:cross_road_ratio] = 4

      10.times do
        board = DivideDungeonMaker.create(80, 80, params)
        board.should be_an_instance_of(Map::Board)

        board.blocks.size.should <= 16 # depth

        room_count = 0
        board.blocks.each do |b|
          b.should be_an_instance_of(Block)
          b.should_not be_an_instance_of(DivideTempBlock)

          b.width.should >= params[:min_block_size]
          b.height.should >= params[:min_block_size]

          next unless b.has_room?
          room = b.room

          room.width.should >= params[:min_room_size]
          room.width.should <= params[:max_room_size]
          room.height.should >= params[:min_room_size]
          room.height.should <= params[:max_room_size]

          room_count += 1
        end

        if board.blocks.size <= 2
          room_count.should == 2
        else
          room_count.should >= params[:min_room_count]
        end
        room_count.should <= params[:max_room_count]
      end
    end

    it "only one big block board" do
      # min_block_sizeの指定が大きいので、min_room_count/max_room_countが影響しない
      params = {}
      params[:min_room_count] = 2
      params[:max_room_count] = 5
      params[:min_block_size] = 99

      10.times do
        board = DivideDungeonMaker.create(40, 40, params)
        board.should be_an_instance_of(Map::Board)

        board.blocks.size.should == 1
        board.blocks.map(&:room).size.should == 1
        board.blocks.inject([]){|l, b| l + b.roads}.should be_empty
      end
    end

    it "only room board" do
      10.times do
        board = DivideDungeonMaker.create(40, 40, :cross_road_ratio => 0)
        board.should be_an_instance_of(Map::Board)

        board.blocks.each do |b|
          b.has_room?.should be_true
          b.has_road?.should be_true
          b.has_cross_point?.should be_false
        end
      end
    end

    it "fixed room count board" do
      (0..2).each do |force_size|
        10.times do
          board = DivideDungeonMaker.create(40, 40, :force_room_count => force_size)
          board.should be_an_instance_of(Map::Board)

          max = board.blocks.size
          expect = (max > force_size ? force_size : max)          
          board.blocks.select{|b| b.has_room?}.size.should == expect
        end
      end
    end

    it "create no blocks if one big block and force no room" do
      params = {}
      params[:force_room_count] = 0
      params[:min_block_size] = 99

      10.times do
        board = DivideDungeonMaker.create(40, 40, params)
        board.should be_an_instance_of(Map::Board)

        board.blocks.size.should == 0
        board.blocks.map(&:room).size.should == 0
      end
    end

  end

  def create_maker_with_blocks(params = nil)
    maker = DivideDungeonMaker.new
    maker.instance_eval do
      @params = params
    end

    tb = maker.create_whole_block(40, 40)
    bl = maker.make_blocks(tb)

    bl.each do |b|
      maker.blocks << b
    end

    maker
  end

end
