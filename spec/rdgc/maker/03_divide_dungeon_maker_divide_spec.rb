# coding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

include RDGC::Map
include RDGC::Maker

describe RDGC::Maker::DivideDungeonMaker, 'is divide block by recursive' do

  describe "each acceptable params" do

    it "min_room_size, max_room_size" do
      maker = DivideDungeonMaker.new
      maker.min_room_size.should be_nil
      maker.max_room_size.should be_nil

      maker.params[:min_room_size] = 5
      maker.params[:max_room_size] = 20

      maker.min_room_size.should == 5
      maker.max_room_size.should == 20
    end

    it "min_block_size" do
      # デフォルト
      maker = DivideDungeonMaker.new
      maker.min_block_size.should == Util::Config.min_block_size

      # デフォルトより小さいとデフォルト
      maker = DivideDungeonMaker.new
      maker.params[:min_block_size] = 1
      maker.min_block_size.should == Util::Config.min_block_size

      maker = DivideDungeonMaker.new
      maker.params[:min_block_size] = 10
      maker.min_block_size.should == 10

      # 一度読むと書き換えできない
      maker.params[:min_block_size] = 20
      maker.min_block_size.should == 10

      # min_room_sizeが存在し、min_block_sizeが存在しない場合、影響を受ける
      maker = DivideDungeonMaker.new
      maker.params[:min_room_size] = 5
      maker.min_block_size.should == 8
    end

    it "min_room_count" do
      # デフォルトは2
      maker = DivideDungeonMaker.new
      maker.min_room_count.should == 2

      # 値は一度だけセットできる
      maker = DivideDungeonMaker.new
      maker.params[:min_room_count] = 3
      maker.min_room_count.should == 3
      maker.params[:min_room_count] = 5
      maker.min_room_count.should == 3

      # 2以下ならデフォルト
      # force_room_countを指定しないと1部屋は作れない
      maker = DivideDungeonMaker.new
      maker.params[:min_room_count] = 1
      maker.min_room_count.should == 2

      maker = DivideDungeonMaker.new
      maker.params[:min_room_count] = 0
      maker.min_room_count.should == 2
    end

    it "max_room_count" do
      maker = DivideDungeonMaker.new
      maker.max_room_count.should == 0

      maker.params[:max_room_count] = 8
      maker.max_room_count.should == 8
    end

    it "max_depth" do
      maker = DivideDungeonMaker.new
      maker.max_depth.should == 0

      maker.params[:max_depth] = 3
      maker.max_depth.should == 3
    end

    it "cross_road_ratio" do
      # デフォルトは2
      maker = DivideDungeonMaker.new
      maker.cross_road_ratio.should == DivideDungeonMaker::DEFAULT_CROSS_ROAD_RATIO

      # 値は一度だけセットできる
      maker = DivideDungeonMaker.new
      maker.params[:cross_road_ratio] = 3
      maker.cross_road_ratio.should == 3
      maker.params[:cross_road_ratio] = 5
      maker.cross_road_ratio.should == 3

      # 0未満ならデフォルト
      maker = DivideDungeonMaker.new
      maker.params[:cross_road_ratio] = -1
      maker.cross_road_ratio.should == 2

      # 0はセット可能
      maker = DivideDungeonMaker.new
      maker.params[:cross_road_ratio] = 0
      maker.cross_road_ratio.should == 0

      # 9を超えるならデフォルト
      maker = DivideDungeonMaker.new
      maker.params[:cross_road_ratio] = 10
      maker.cross_road_ratio.should == 2
    end

    it "force_room_count" do
      maker = DivideDungeonMaker.new
      maker.force_room_count.should be_nil
      # force_room_countを指定すると、min_room_countに影響する
      maker.min_room_count.should == 2

      maker.params[:force_room_count] = 1
      maker.force_room_count.should == 1
      maker.min_room_count.should == 1

      maker.params[:force_room_count] = 0
      maker.force_room_count.should == 0
      maker.min_room_count.should == 0
    end

  end

  describe "divide whole_block" do

    it "divide_queue store dividable block, and done_queue store divided block" do
      maker = DivideDungeonMaker.new
      maker.queue_size.should == 0

      maker.divide_queue << DivideTempBlock.create_whole_block(20, 20)
      maker.divide_queue.size.should == 1
      maker.queue_size.should == 1

      maker.done_queue << DivideTempBlock.create_whole_block(20, 20)
      maker.done_queue.size.should == 1
      maker.queue_size.should == 2
    end

    it "#finish? will check divide end" do
      maker = DivideDungeonMaker.new
      maker.finish?.should be_true

      maker.done_queue << DivideTempBlock.create_whole_block(20, 20)
      maker.finish?.should be_true

      maker.divide_queue << DivideTempBlock.create_whole_block(20, 20)
      maker.finish?.should be_false

      maker.params[:max_block_count] = 3
      maker.finish?.should be_false

      maker.done_queue << DivideTempBlock.create_whole_block(20, 20)
      maker.finish?.should be_true
    end

    it "#dividable_block? check block dividable" do
      # max_depthの指定がない場合
      maker = DivideDungeonMaker.new
      b = DivideTempBlock.create_whole_block(20, 20)

      maker.dividable_block?(b).should be_false
      b.dividable
      maker.dividable_block?(b).should be_true

      # max_depthが指定されている場合
      maker = DivideDungeonMaker.new
      maker.params[:max_depth] = 3
      b = DivideTempBlock.create_whole_block(20, 20)

      b.dividable
      maker.dividable_block?(b).should be_true
      b.depth = 3
      maker.dividable_block?(b).should be_false
    end

    it "create_whole_block" do
      maker = DivideDungeonMaker.new
      tb = maker.create_whole_block(30, 40)
      tb.should be_an_instance_of(DivideTempBlock)
      tb.width.should == 30
      tb.height.should == 40
      tb.min_size.should == Util::Config.min_block_size
      tb.dividable?.should be_true
    end

    it "divide block" do
      each_create_block do |b|
        b.should be_an_instance_of(DivideTempBlock)
      end
    end

    it "min_block_size/max_block_count/max_depth affect divide as possible" do
      10.times do
        each_create_block(:min_block_size, 6) do |b|
          b.should be_an_instance_of(DivideTempBlock)
          b.width.should >= 6
          b.height.should >= 6
        end
      end

      10.times do
        count = 0
        each_create_block(:max_block_count, 5) do |b|
          b.should be_an_instance_of(DivideTempBlock)
          count += 1
        end
        count.should <= 5
      end

      10.times do
        count = 0
        each_create_block(:max_depth, 3) do |b|
          b.should be_an_instance_of(DivideTempBlock)
          b.depth.should <= 3
          count += 1
        end
        count.should <= 8
      end
    end

    it "min_block_count affect divide as possible" do
      (8..20).each do |ts|
        10.times do
          count = 0
          remain = 0
          each_create_block(:min_block_count, ts) do |b|
            b.should be_an_instance_of(DivideTempBlock)
            remain += 1 if b.dividable_size?
            count += 1
          end
          
          if count >= ts
            count.should >= ts # always OK
          else
            # min_block_countを満たせない場合に、分割がもう限界であるか？
            remain.should <= 0
          end
        end
      end
    end

    def each_create_block(name = nil, val = nil)
      maker = DivideDungeonMaker.new
      maker.params[name] = val if name && val
      tb = maker.create_whole_block(40, 40)
      bl = maker.make_blocks(tb)

      bl.each{|b| yield(b)}
    end

  end

end
