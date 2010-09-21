# coding: UTF-8
module RDGC
  module Map
    class Block < Area

      def self.create(top, bottom, left, right)
        # fillはしない
        super(top, bottom, left, right)
      end

      def fill
        # 初期化
        fill_tile TileType::WALL

        fill_room
        fill_roads

        self
      end

      def fill_room
        return unless has_room?
        room.each_tile do |x, y, t|
          set_tile(x, y, t)
        end

        self
      end

      def fill_roads
        return unless has_road?
        roads.each do |r|
          r.each_tile do |x, y, t|
            set_tile(x, y, t)
          end
        end

        self
      end

      def room
        @room
      end

      def room=(r)
        @room = r
      end

      def remove_room
        @room = nil
      end

      def has_room?
        @room ? true : false
      end

      def create_room(opt = nil)
        @room = Room.create_from_block(self, opt)
        @room
      end

      def roads
        @roads ||= []
        @roads
      end

      def add_road(road)
        @roads ||= []
        @roads << road
      end

      def remove_roads
        @roads = []
      end

      def has_road?
        roads.empty? ? false : true
      end

      def cross_point
        @cross_point
      end

      def remove_cross_point
        @cross_point = nil
      end

      def has_cross_point?
        @cross_point ? true : false
      end

      def create_cross_point
        # 右と下は接線を引くので余計に空ける
        x_min = self.left + 1
        x_max = self.right - 2
        y_min = self.top + 1
        y_max = self.bottom - 2

        x = range_rand(x_min, x_max)
        y = range_rand(y_min, y_max)

        @cross_point = [x, y]
        @cross_point
      end

      def remove_all
        remove_room
        remove_roads
        remove_cross_point
        self
      end

      def empty?
        return false if has_room?
        return false if has_road?
        true
      end

      def cling_to_top?(b)
        return false unless top == b.bottom+1
        return false if left > b.right
        return false if right < b.left
        true
      end

      def cling_to_bottom?(b)
        return false unless bottom == b.top-1
        return false if left > b.right
        return false if right < b.left
        true
      end

      def cling_to_left?(b)
        return false unless left == b.right+1
        return false if top > b.bottom
        return false if bottom < b.top
        true
      end

      def cling_to_right?(b)
        return false unless right == b.left-1
        return false if top > b.bottom
        return false if bottom < b.top
        true
      end

      def cling_direction_to(b)
        case
        when cling_to_top?(b)
          :top
        when cling_to_bottom?(b)
          :bottom
        when cling_to_left?(b)
          :left
        when cling_to_right?(b)
          :right
        end
      end

    end
  end
end
