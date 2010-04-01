# coding: UTF-8
module RDGC
  module Maker
    class TempBlock < Map::Block

      def self.create_whole_block(width, height)
        left = 0
        right = width - 1
        top = 0
        bottom = height - 1
        self.create(top, bottom, left, right)
      end

      def create_pure_block
        b = Map::Block.create(self.top, self.bottom, self.left, self.right)
        b.room = self.room if self.has_room?
        self.roads.each{|r| b.add_road(r) if r}
        b.empty? ? nil : b
      end

    end
  end
end