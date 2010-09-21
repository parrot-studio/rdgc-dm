# coding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

include RDGC::Map

describe "blind mode" do

  describe RDGC::Map::Area, "with blind" do

    before do
      @area = Area.new
    end

    it "level none" do
      @area.set_blind(:none)

      @area.blind_level.should == :none
      @area.blind_level_none?.should be_true
      @area.blind_level_open?.should be_false
      @area.blind_level_blind?.should be_false
      @area.blind_level_dark?.should be_false
    end

    it "level open" do
      @area.set_blind(:open)

      @area.blind_level.should == :open
      @area.blind_level_none?.should be_false
      @area.blind_level_open?.should be_true
      @area.blind_level_blind?.should be_false
      @area.blind_level_dark?.should be_false
    end

    it "level blind" do
      @area.set_blind(:blind)

      @area.blind_level.should == :blind
      @area.blind_level_none?.should be_false
      @area.blind_level_open?.should be_false
      @area.blind_level_blind?.should be_true
      @area.blind_level_dark?.should be_false
    end

    it "level dark" do
      @area.set_blind(:dark)

      @area.blind_level.should == :dark
      @area.blind_level_none?.should be_false
      @area.blind_level_open?.should be_false
      @area.blind_level_blind?.should be_false
      @area.blind_level_dark?.should be_true
    end

    it "unexpected level" do
      @area.set_blind(:hoge)

      @area.blind_level.should be_nil
      @area.blind_level_none?.should be_false
      @area.blind_level_open?.should be_false
      @area.blind_level_blind?.should be_false
      @area.blind_level_dark?.should be_false
    end

  end

  describe RDGC::Map::Board, "with blind" do

    before do
      @board = Board.create(0, 20, 0, 20)

      @room = Room.create(5, 15, 5, 15)
      @road1 = Road.create(0, 4, 10, 10)
      @road2 = Road.create(16, 20, 12, 12)

      @board.rooms << @room
      @board.roads << @road1
      @board.roads << @road2
      @board.fill
    end

    it "#blind_level/#set_blind is disable" do
      [:none, :open, :blind, :dark].each do |lv|
        @board.set_blind(lv)

        @board.blind_level.should be_nil
        @board.blind_level_none?.should be_false
        @board.blind_level_open?.should be_false
        @board.blind_level_blind?.should be_false
        @board.blind_level_dark?.should be_false
      end
    end

    it "#init_blind_all will set :blind to all rooms/roads" do
      @board.init_blind_all(:none)
      @board.areas.each do |a|
        a.blind_level_none?.should be_true
      end

      @board.init_blind_all(:blind)
      @board.areas.each do |a|
        a.blind_level_blind?.should be_true
      end
    end

    it "#init_blind_normal will set :blind to roads, :open to rooms" do
      @board.init_blind_normal

      @room.blind_level_open?.should be_true
      @road1.blind_level_blind?.should be_true
      @road2.blind_level_blind?.should be_true
    end

    it "#init_blind will set blind_level each rooms/roads as blind_mode" do
      @board.instance_eval do
        @blind_mode = Board::BLIND_MODE_NONE
      end
      @board.init_blind

      @room.blind_level_none?.should be_true
      @road1.blind_level_none?.should be_true
      @road2.blind_level_none?.should be_true

      @board.instance_eval do
        @blind_mode = Board::BLIND_MODE_NORMAL
      end
      @board.init_blind

      @room.blind_level_open?.should be_true
      @road1.blind_level_blind?.should be_true
      @road2.blind_level_blind?.should be_true

      @board.instance_eval do
        @blind_mode = Board::BLIND_MODE_BLIND
      end
      @board.init_blind

      @room.blind_level_blind?.should be_true
      @road1.blind_level_blind?.should be_true
      @road2.blind_level_blind?.should be_true
    end

    it "#set_blind_mode will set blind_mode, and init_blind" do
      @board.blind_mode?.should be_false

      @board.set_blind_mode(Board::BLIND_MODE_NONE)
      @board.blind_mode.should == Board::BLIND_MODE_NONE
      @board.blind_mode?.should be_true

      @room.blind_level_none?.should be_true
      @road1.blind_level_none?.should be_true
      @road2.blind_level_none?.should be_true

      @board.set_blind_mode(Board::BLIND_MODE_NORMAL)
      @board.blind_mode.should == Board::BLIND_MODE_NORMAL
      @board.blind_mode?.should be_true

      @room.blind_level_open?.should be_true
      @road1.blind_level_blind?.should be_true
      @road2.blind_level_blind?.should be_true

      @board.set_blind_mode(Board::BLIND_MODE_BLIND)
      @board.blind_mode.should == Board::BLIND_MODE_BLIND
      @board.blind_mode?.should be_true

      @room.blind_level_blind?.should be_true
      @road1.blind_level_blind?.should be_true
      @road2.blind_level_blind?.should be_true

      @board.set_blind_mode
      @board.blind_mode.should == Board::BLIND_MODE_NORMAL
      @board.blind_mode?.should be_true

      @room.blind_level_open?.should be_true
      @road1.blind_level_blind?.should be_true
      @road2.blind_level_blind?.should be_true
    end

    it "#blind_state/#set_blind_state will get/set blind_state" do
      @board.set_blind_state(10, 9, :blind)
      @board.blind_state(10, 9).should == :blind
    end

    it "#fill_blind will fill blind_data as each area's blind_level" do
      @board.set_blind_mode
      @board.fill_blind

      @board.areas.each do |r|
        r.each do |x, y|
          @board.blind_state(x, y).should == :blind
        end
      end

      @board.set_blind_mode(:none)
      @board.fill_blind

      @board.areas.each do |r|
        r.each do |x, y|
          @board.blind_state(x, y).should == :none
        end
      end
    end

    it "#dark? judge this point is :dark now" do
      @board.set_blind_mode
      @room.set_blind(:dark)
      @room.blind_level_dark?.should be_true
      @board.fill_blind

      @room.each.all?{|x, y| @board.dark?(x, y)}.should be_true

      tx, ty = @room.random_point
      @board.set_blind_state(tx, ty, :none)
      @board.dark?(tx, ty).should be_false
    end

    it "#fill_dark_before_cancel" do
      @board.set_blind_mode
      @room.set_blind(:dark)
      @room.blind_level_dark?.should be_true
      @board.fill_blind

      5.times do
        tx, ty = @room.random_point
        @board.set_blind_state(tx, ty, :none)
      end
      @room.each.all?{|x, y| @board.dark?(x, y)}.should be_false

      @board.instance_eval do
        fill_dark_before_cancel
      end
      @room.each.all?{|x, y| @board.dark?(x, y)}.should be_true
    end

    it "#open_blind will clear blind stat recursive" do
      @board.set_blind_mode(Board::BLIND_MODE_BLIND)
      @board.fill_blind

      @board.open_blind(10, 4, 0)
      @board.blind_state(10, 4).should == :none
      @board.blind_state(10, 3).should == :blind
      @board.blind_state(10, 5).should == :blind

      @board.open_blind(10, 4, 1)
      @board.blind_state(10, 4).should == :none
      @board.blind_state(10, 3).should == :none
      @board.blind_state(10, 5).should == :none
      @board.blind_state(10, 2).should == :blind
      @board.blind_state(10, 6).should == :blind

      @board.open_blind(10, 4, 2)
      @board.blind_state(10, 4).should == :none
      @board.blind_state(10, 3).should == :none
      @board.blind_state(10, 2).should == :none
      @board.blind_state(10, 1).should == :blind

      @board.blind_state(10, 5).should == :none
      @board.blind_state(9, 5).should == :none
      @board.blind_state(10, 6).should == :none
      @board.blind_state(11, 5).should == :none

      @board.blind_state(8, 5).should == :blind
      @board.blind_state(12, 5).should == :blind
      @board.blind_state(9, 6).should == :blind
      @board.blind_state(11, 6).should == :blind
      @board.blind_state(10, 7).should == :blind
    end

    it "#open_blind will clear blind all of area for :open" do
      @board.set_blind_mode
      @board.fill_blind

      @board.open_blind(10, 4, 1)
      @board.blind_state(10, 4).should == :none
      @board.blind_state(10, 3).should == :none
      @board.blind_state(10, 5).should == :none
      @board.blind_state(10, 2).should == :blind

      @room.each do |x, y|
        @board.blind_state(x, y).should == :none
      end
    end

    it "#open_blind will clear blind, and turn to dark for opened point" do
      @board.set_blind_mode
      @room.set_blind(:dark)
      @board.fill_blind

      # 1歩目
      @board.open_blind(10, 5, 1)

      @board.blind_state(10, 4).should == :none

      @board.blind_state(10, 5).should == :none
      @board.blind_state(9, 5).should == :none
      @board.blind_state(11, 5).should == :none
      @board.blind_state(10, 6).should == :none

      # 2歩目
      @board.open_blind(10, 6, 1)
      @board.blind_state(10, 4).should == :none

      @board.blind_state(10, 6).should == :none
      @board.blind_state(9, 6).should == :none
      @board.blind_state(11, 6).should == :none
      @board.blind_state(10, 5).should == :none
      @board.blind_state(10, 7).should == :none

      @board.blind_state(9, 5).should == :dark
      @board.blind_state(11, 5).should == :dark
    end

    it "#visible?/#invisible?" do
      @board.set_blind_mode
      @road2.set_blind(:dark)
      @board.fill_blind

      @board.open_blind(10, 4, 1)
      @board.visible?(10, 4).should be_true
      @board.visible?(10, 3).should be_true
      @board.visible?(10, 5).should be_true
      @board.visible?(10, 2).should be_false
      @board.invisible?(10, 2).should be_true

      @room.each do |x, y|
        @board.visible?(x, y).should be_true
        @board.invisible?(x, y).should be_false
      end

      # dark
      tx, ty = @road2.random_point
      @board.visible?(tx, ty).should be_false
      @board.invisible?(tx, ty).should be_true

      # out of range
      @board.visible?(30, 30).should be_false
      @board.invisible?(30, 30).should be_true
    end

  end

end
