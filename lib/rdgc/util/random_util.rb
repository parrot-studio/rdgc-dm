# coding: UTF-8
module RDGC
  module Util
    module RandomUtil

      module_function

      def bool_rand
        case rand(2)
        when 1
          true
        when 0
          false
        end
      end

      def range_rand(s_val, e_val)
        return s_val if e_val <= s_val
        s_val + rand((e_val - s_val)+1)
      end

      def select_rand(hash)
        return unless hash
        return if hash.empty?

        range_list = []
        count = 0
        hash.each do |k, v|
          range = count...(count + v)
          range_list << [range, k]
          count += v
        end
        return if count <= 0

        val = rand(count)

        ret = nil
        range_list.each do |r|
          if r.first.include?(val)
            ret = r.last
            break
          end
        end

        ret
      end

      def dice(n, max)
        ret = 0
        n.times{ret += range_rand(1, max)}
        ret
      end

    end
  end
end

class Integer

  def dice(max)
    RDGC::Util::RandomUtil.dice(self, max)
  end
  alias :d :dice

  def method_missing(name, *args)
    try_define_dice(name, args) ? (__send__ name) : super
  end

  def d4
    self.dice(4)
  end

  def d6
    self.dice(6)
  end

  def d10
    self.dice(10)
  end

  private

  def try_define_dice(name, args)
    return false if args.size > 0

    m = name.to_s.match(/^[d|D](\d+)$/)
    return false unless m
    return false if m[1].to_i <= 0

    self.class.module_eval("def #{name};self.dice(#{m[1]});end")
    true
  end

end

class Array

  def pickup!
    ret = self.choice
    self.delete(ret)
    ret
  end

  if RUBY_VERSION >= '1.9.1'
    def choice
      self.sample
    end
  end

end