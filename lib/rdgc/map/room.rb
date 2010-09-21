# coding: UTF-8
module RDGC
  module Map
    class Room < Area

      def self.create(top, bottom, left, right)
        room = super(top, bottom, left, right)
        room.fill
        room
      end

      def self.create_from_block(b, opt = nil)
        room_w = room_size(b.width, opt)
        room_h = room_size(b.height, opt)
        return if (room_w <= 0 || room_h <= 0)

        l_point = b.left+1 + room_point(b.width, room_w)
        t_point = b.top+1 + room_point(b.height, room_h)

        self.create(t_point, t_point + room_h - 1, l_point, l_point + room_w - 1)
      end

      def fill
        fill_tile TileType::ROOM
        self
      end

      private

      def self.room_size(val, opt = nil)
        opt ||= {}

        # 部屋の最大サイズ = ブロックサイズ-壁1*2-通路1
        base = val - 3
        return 0 if base < Util::Config.min_room_size

        # 最小値・最大値判定
        min = min_size(base, opt[:min])
        max = max_size(base, opt[:max])
        min = max if min > max

        range_rand(min, max)
      end

      def self.min_size(base, min)
        min_room_size = Util::Config.min_room_size

        return min_room_size unless min
        min = min.to_i
        return base if base < min
        return min_room_size if min < min_room_size
        min
      end

      def self.max_size(base, max)
        return base unless max
        max = max.to_i
        return base if max > base
        return Util::Config.min_room_size if max < Util::Config.min_room_size
        max
      end

      def self.room_point(block_size, room_size)
        # 右と下は余分に空ける => 結ぶ通路は左と上が担当
        range_rand(0, block_size - 3 - room_size)
      end

    end
  end
end
