# coding: UTF-8
module RDGC
  module Map
    class Tile

      def initialize(type)
        @type = type
        @type.freeze
      end

      def movable?
        return false if out?
        return false if wall?
        true
      end

      def out?
        @type == :out ? true : false
      end

      def wall?
        @type == :wall ? true : false
      end

      def room?
        @type == :room ? true : false
      end

      def road?
        @type == :road ? true : false
      end

    end
  end
end
