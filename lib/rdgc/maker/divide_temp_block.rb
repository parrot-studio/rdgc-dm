# coding: UTF-8
module RDGC
  module Maker
    class DivideTempBlock < TempBlock

      attr_accessor :divide_direction
      attr_writer :depth, :min_size

      def depth
        @depth ||= 0
        @depth
      end

      def min_size
        @min_size = Util::Config.min_block_size if @min_size.to_i < Util::Config.min_block_size
        @min_size
      end

      def min_divide_size
        min_size * 2
      end

      def opposite_direction
        case self.divide_direction
        when :horizontal
          :vertical
        when :vertical
          :horizontal
        else
          nil
        end
      end

      def dividable_size?
        case self.divide_direction
        when :horizontal
          height >= min_divide_size ? true : false
        when :vertical
          width >= min_divide_size ? true : false
        else
          false
        end
      end

      def dividable(f = true)
        @dividable = f
      end

      def dividable?
        @dividable
      end

      def set_dividable
        return unless dividable_size?
        dividable
      end

      def divide_point(val)
        range_rand(min_size, val - min_divide_size)
      end

      def divide
        self.divide_direction ||= select_rand({:horizontal => 1, :vertical => 1})
        return unless dividable_size?

        case self.divide_direction
        when :horizontal
          divide_horizontal
        when :vertical
          divide_vertical
        end
      end

      def divide_horizontal
        return unless dividable_size?

        # 分割幅決定
        point = divide_point(height)

        upper = DivideTempBlock.create(top, top + point - 1, left, right)
        lower = DivideTempBlock.create(top + point, bottom, left, right)

        set_next_value(upper, lower)
        [upper, lower].shuffle
      end

      def divide_vertical
        return unless dividable_size?

        # 分割点決定
        point = divide_point(width)

        lefter = DivideTempBlock.create(top, bottom, left, left + point - 1)
        righter = DivideTempBlock.create(top, bottom, left + point, right)

        set_next_value(lefter, righter)
        [lefter, righter].shuffle
      end

      def set_next_value(b1, b2)
        [b1, b2].each do |b|
          b.depth = self.depth + 1
          b.divide_direction = opposite_direction
          b.min_size = min_size
        end

        if bool_rand
          b1.set_dividable
          b2.set_dividable if bool_rand
        else
          b2.set_dividable
          b1.set_dividable if bool_rand
        end
      end

      # for road ----------------------------------------------------

      def road_created(f = true)
        @road_created = f
        self
      end

      def road_created?
        @road_created
      end

      def set_road_point(direction, point)
        @road_point ||= {}
        @road_point[direction] = point
      end

      def road_point
        @road_point ||= {}
        @road_point
      end

      def remain_cling_blocks
        @remain_cling_blocks ||= []
        @remain_cling_blocks
      end

      def add_remain_cling_blocks(b)
        return if b.has_room?
        remain_cling_blocks << b
      end

      def has_remain_cling_blocks?
        remain_cling_blocks.empty? ? false : true
      end

      def dead_end?
        return false if has_room?
        return false unless has_cross_point?
        road_point.keys.size == 1 ? true : false
      end

      def remain_direction
        [:top, :bottom, :left, :right] - road_point.keys
      end

      def create_road_to(b)
        return unless (has_room? || has_cross_point?)
        return unless (b.has_room? || b.has_cross_point?)

        # 相手とどこで接しているか調べる
        # 接線に向かって道を伸ばす
        # 左か上に位置する部屋に接続線を引く
        case cling_direction_to(b)
        when :top
          my_x = create_road_for_direction(:top)
          b_x = b.create_road_for_direction(:bottom)
          b.create_road_for_adjoin_x(my_x, b_x)
        when :bottom
          my_x = create_road_for_direction(:bottom)
          b_x = b.create_road_for_direction(:top)
          create_road_for_adjoin_x(my_x, b_x)
        when :left
          my_y = create_road_for_direction(:left)
          b_y = b.create_road_for_direction(:right)
          b.create_road_for_adjoin_y(my_y, b_y)
        when :right
          my_y = create_road_for_direction(:right)
          b_y = b.create_road_for_direction(:left)
          create_road_for_adjoin_y(my_y, b_y)
        end
      end

      def create_road_for_direction(d)
        # 道を描くポイントを持っている（すでに道がある）ならそれを返す
        val = road_point[d]
        return val if val

        # 新しい道を描く
        case
        when has_room?
          val = create_road_from_room(d)
        when has_cross_point?
          val = create_road_from_point(d)
        end

        val
      end

      def create_road_from_room(d)
        return unless has_room?
        return if road_point[d]

        case d
        when :top
          x = range_rand(room.left, room.right)
          set_road_point(:top, x)
          add_road(Map::Road.create(top, room.top-1, x, x))
          x
        when :bottom
          x = range_rand(room.left, room.right)
          set_road_point(:bottom, x)
          add_road(Map::Road.create(room.bottom+1, bottom, x, x))
          x
        when :left
          y = range_rand(room.top, room.bottom)
          set_road_point(:left, y)
          add_road(Map::Road.create(y, y, left, room.left-1))
          y
        when :right
          y = range_rand(room.top, room.bottom)
          set_road_point(:right, y)
          add_road(Map::Road.create(y, y, room.right+1, right))
          y
        end
      end

      def create_road_from_point(d)
        return unless has_cross_point?
        return if road_point[d]

        x, y = cross_point
        case d
        when :top
          set_road_point(:top, x)
          add_road(Map::Road.create(top, y, x, x))
          x
        when :bottom
          set_road_point(:bottom, x)
          add_road(Map::Road.create(y, bottom, x, x))
          x
        when :left
          set_road_point(:left, y)
          add_road(Map::Road.create(y, y, left, x))
          y
        when :right
          set_road_point(:right, y)
          add_road(Map::Road.create(y, y, x, right))
          y
        end
      end

      def create_road_for_adjoin_x(x1, x2)
        p_s, p_e = [x1, x2].sort
        add_road(Map::Road.create(bottom, bottom, p_s, p_e))
      end

      def create_road_for_adjoin_y(y1, y2)
        p_s, p_e = [y1, y2].sort
        add_road(Map::Road.create(p_s, p_e, right, right))
      end

    end
  end
end
