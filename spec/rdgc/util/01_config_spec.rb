# coding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

include RDGC::Util

describe RDGC::Util::Config do

  it "default value" do
    Util::Config.min_room_size.should == 4
    Util::Config.min_block_size.should == 7
    Util::Config.act_max_count.should == 200
  end

  it "value change only once, and #reset! will force change default value" do
    val1 = {
      :min_room_size => 5,
      :act_max_count => 100
    }

    Util::Config.set(val1).should be_true
    Util::Config.min_room_size.should == 5
    Util::Config.act_max_count.should == 100

    val2 = {
      :min_room_size => 10,
      :act_max_count => 80
    }

    Util::Config.set(val2).should be_false
    Util::Config.min_room_size.should == 5
    Util::Config.act_max_count.should == 100

    Util::Config.reset!.should be_true
    Util::Config.min_room_size.should == 4
    Util::Config.act_max_count.should == 200

    Util::Config.set(val2).should be_true
    Util::Config.min_room_size.should == 10
    Util::Config.act_max_count.should == 80

    Util::Config.reset!.should be_true
  end

end
