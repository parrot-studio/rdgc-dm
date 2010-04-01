# coding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

include RDGC::Util

describe RDGC::Util::RandomUtil do

  it "bool_rand provides true or false" do
    100.times do
      [true, false].should be_include(bool_rand)
    end
  end

  describe "range_rand provides s_val <= val <= e_val" do

    it "give s_val and e_val" do
      s_val = 1
      e_val = 10

      100.times do
        ret = range_rand(s_val, e_val)
        ret.should >= s_val
        ret.should <= e_val
      end
    end

    it "return s_val if s_val > e_val" do
      s_val = 15
      e_val = 1

      100.times do
        ret = range_rand(s_val, e_val)
        ret.should == s_val
      end
    end

  end

  describe "select_rand provides hash key at random" do

    it "select random key" do
      hash = {:k1 => 10, :k2 => 5, :k3 => 3}
      expect = [:k1, :k2, :k3]

      100.times do
        ret = select_rand(hash)
        expect.should be_include(ret)
      end
    end

    it "never return key if value = 0" do
      hash = {:k1 => 1, :k2 => 1, :k3 => 0}
      expect = [:k1, :k2]

      100.times do
        ret = select_rand(hash)
        expect.should be_include(ret)
      end
    end

    it "return nil, if hash is nil or values sum 0" do
      hash = {:k1 => 0, :k2 => 0, :k3 => 0}

      10.times do
        ret = select_rand(hash)
        ret.should be_nil
      end

      10.times do
        ret = select_rand(nil)
        ret.should be_nil
      end
    end

  end

  describe "dice provides value like (n-dice * times)" do

    it "dice(1, n) behave n-dice" do
      [4, 6, 10].each do |n|
        100.times do
          val = dice(1, n)
          val.should >= 1
          val.should <= n
        end
      end
    end

    it "dice(n, 6) behave 6-dice roll n-times" do
      (1..10).each do |n|
        100.times do
          val = dice(n, 6)
          val.should >= (1 * n)
          val.should <= (6 * n)
        end
      end
    end

  end

  describe "define Integer#dice" do

    it "#d4 #d6 #d10 provides each-dice roll self-times" do
      (1..10).each do |n|
        100.times do
          d4 = n.d4
          d4.should >= (1 * n)
          d4.should <= (4 * n)

          d6 = n.d6
          d6.should >= (1 * n)
          d6.should <= (6 * n)

          d10 = n.d10
          d10.should >= (1 * n)
          d10.should <= (10 * n)
        end
      end
    end

    it "any number dice can use, example 4.d5, 3.d16" do
      100.times do
        val1 = 4.d5
        val1.should >= (1 * 4)
        val1.should <= (5 * 4)

        val2 = 3.d16
        val2.should >= (1 * 3)
        val2.should <= (16 * 3)
      end
    end

  end

  describe "define Array#pickup!" do

    it "#pickup! shift random value in Array" do
      array = [1, 2, 3, 4, 5]
      list = array.dup

      array.size.times do |i|
        ret = list.pickup!
        array.should be_include(ret)
        list.should_not be_include(ret)
        list.size.should == array.size - (i+1)
      end

      list.should be_empty
    end

  end

end
