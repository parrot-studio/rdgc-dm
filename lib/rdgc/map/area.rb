# coding: UTF-8
module RDGC
  module Map
    class Area
      include TileType

      attr_accessor :top, :bottom, :left, :right

      def self.create(top, bottom, left, right)
        b = self.new
        b.top = top
        b.bottom = bottom
        b.left = left
        b.right = right
        b
      end

      def coordinates
        "t:#{top} b:#{bottom} l:#{left} r:#{right} / w:#{width} h:#{height}"
      end

      alias :to_co :coordinates

      def height
        bottom - top + 1
      end

      def width
        right - left + 1
      end

      def has_xy?(x, y)
        return false if x < left
        return false if x > right
        return false if y < top
        return false if y > bottom
        true
      end

      def random_point
        [range_rand(left, right), range_rand(top, bottom)]
      end

      def each
        return to_enum(:each) unless block_given?
        each_x do |x|
          each_y do |y|
            yield(x, y)
          end
        end
      end

      def each_x
        return to_enum(:each_x) unless block_given?
        (left..right).each do |x|
          yield(x)
        end
      end

      def each_y
        return to_enum(:each_y) unless block_given?
        (top..bottom).each do |y|
          yield(y)
        end
      end

      def each_tile
        return to_enum(:each_tile) unless block_given?
        each do |x, y|
          yield(x, y, tile(x, y))
        end
      end

      def fill
        # need override
      end

      def fill_tile(tile)
        each do |x, y|
          set_tile(x, y, tile)
        end

        self
      end

      def set_tile(x, y, tile)
        return unless has_xy?(x, y)
        tile_data[x][y] = tile
      end

      def tile(x, y)
        return unless has_xy?(x, y)
        tile_data[x][y]
      end

      private

      def tile_data
        @tile_data ||= Hash.new{|hash, key| hash[key] = {}}
        @tile_data
      end

    end
  end
end