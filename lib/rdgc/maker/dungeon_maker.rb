# coding: UTF-8
module RDGC
  module Maker
    module DungeonMaker

      def make(width, height, params = nil)
        @params = params
        tb = create_whole_block(width, height)
        @blocks = make_blocks(tb)
        @blocks.freeze
        create_room
        create_road
        clear_block
        create_pure_blocks
      end

      def params
        @params ||= {}
        @params
      end

      def blocks
        @blocks ||= []
        @blocks
      end

      def create_whole_block(width, height)
      end

      def make_blocks(tb)
      end

      def create_room
      end

      def create_road
      end

      def clear_block
        return if blocks.size <= 1
        blocks.each do |b|
          next if b.has_road?
          b.remove_all
        end
      end

      def create_pure_blocks
        blocks.inject([]) do |l, b|
          pb = b.create_pure_block
          l << pb if pb
          l
        end
      end

    end
  end
end
