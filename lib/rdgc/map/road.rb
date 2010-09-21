# coding: UTF-8
module RDGC
  module Map
    class Road < Area

      def self.create(top, bottom, left, right)
        road = super(top, bottom, left, right)
        road.fill
        road
      end

      def fill
        fill_tile TileType::ROAD
        self
      end

    end
  end
end
