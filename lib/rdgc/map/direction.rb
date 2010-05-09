# -*- coding: UTF-8 -*-
module RDGC
  module Map
    class Direction

      attr_reader :x, :y

      private

      def self.create(x, y)
        obj = self.new

        obj.instance_eval do
          @x = x
          @y = y
        end

        obj.freeze
        obj
      end

      public

      SELF = self.create(0, 0)
      LEFT = self.create(-1, 0)
      RIGHT = self.create(1, 0)
      UPPER = self.create(0, -1)
      BOTTOM = self.create(0, 1)

      def self.each
        return to_enum(:each) unless block_given?
        self.all.each do |d|
          yield(d)
        end
      end

      def self.all
        [LEFT, UPPER, RIGHT, BOTTOM]
      end

      def opposite
        case self
        when LEFT
          RIGHT
        when RIGHT
          LEFT
        when UPPER
          BOTTOM
        when BOTTOM
          UPPER
        when SELF
          SELF
        end
      end

    end
  end
end