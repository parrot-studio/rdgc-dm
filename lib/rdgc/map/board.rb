# coding: UTF-8
module RDGC
  module Map
    class Board < Area

      def self.create_from_blocks(blocks)
        d = self.new
        d.init(blocks)
        d
      end

      def init(list)
        return unless list
        return if list.empty?

        @blocks = list
        @rooms = blocks.map(&:room).compact
        @roads = blocks.map(&:roads).flatten.compact

        set_coordinates
        fill

        self
      end

      def set_coordinates
        return unless blocks
        self.top = blocks.map(&:top).min
        self.bottom = blocks.map(&:bottom).max
        self.left = blocks.map(&:left).min
        self.right = blocks.map(&:right).max

        self
      end

      def fill
        # 初期化
        fill_tile TileType::WALL

        rooms.each do |r|
          r.each_tile do |x, y, t|
            set_tile(x, y, t)
          end
        end

        roads.each do |r|
          r.each_tile do |x, y, t|
            set_tile(x, y, t)
          end
        end

        self
      end

      def blocks
        @blocks ||= []
        @blocks
      end

      def rooms
        @rooms ||= []
        @rooms
      end

      def roads
        @roads ||= []
        @roads
      end

      def areas
        [rooms, roads].flatten
      end

      def areas_for(x, y)
        areas.select{|a| a.has_xy?(x, y)}
      end

      def movable?(x, y)
        return false unless has_xy?(x, y)
        tile(x, y).movable?
      end

      def room?(x, y)
        return false unless has_xy?(x, y)
        tile(x, y).room?
      end

      def road?(x, y)
        return false unless has_xy?(x, y)
        tile(x, y).road?
      end

    end
  end
end
