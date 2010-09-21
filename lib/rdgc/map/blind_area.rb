# coding: UTF-8
module RDGC
  module Map

    class Area

      def blind_level
        @blind_level
      end

      def set_blind(level)
        return unless [:none, :open, :blind, :dark].include?(level)
        @blind_level = level
        self
      end

      def blind_level_none?
        blind_level == :none ? true : false
      end

      def blind_level_open?
        blind_level == :open ? true : false
      end

      def blind_level_blind?
        blind_level == :blind ? true : false
      end

      def blind_level_dark?
        blind_level == :dark ? true : false
      end

    end # Area

    class Board

      BLIND_MODE_NONE = :none
      BLIND_MODE_NORMAL = :normal
      BLIND_MODE_BLIND = :blind

      # override
      def blind_level
        # do nothing
      end

      # override
      def set_blind(level)
        # do nothing
      end

      def set_blind_mode(mode = nil)
        @blind_mode = mode
        @blind_mode ||= BLIND_MODE_NORMAL
        init_blind
        self
      end

      def blind_mode
        @blind_mode
      end

      def blind_mode?
        @blind_mode ? true : false
      end

      def fill_blind
        areas.each do |r|
          case
          when r.blind_level_none?
            target = :none
          when r.blind_level_dark?
            target = :dark
          else
            target = :blind
          end

          r.each do |x, y|
            blind_data[x][y] = target
          end
        end

        self
      end

      def visible?(x, y)
        return false unless has_xy?(x, y)
        return true unless blind_mode?
        v = blind_data[x][y]
        return false unless v
        v == :none ? true : false
      end

      def invisible?(x, y)
        ! visible?(x, y)
      end

      def dark?(x, y)
        return false unless has_xy?(x, y)
        blind_data[x][y] == :dark ? true : false
      end

      def open_blind(sx, sy, range)
        return unless movable?(sx, sy)

        # 先にdarkのエリアを塗りつぶす
        fill_dark_before_cancel

        # 再帰処理で解除
        open_list = []
        cancel_blind(sx, sy, open_list, range)

        # :openのareaを全解除
        return if open_list.empty?
        open_list.uniq.each do |a|
          a.each do |x, y|
            blind_data[x][y] = :none
          end
        end

        self
      end

      def init_blind
        case blind_mode
        when BLIND_MODE_NONE
          init_blind_all(:none)
        when BLIND_MODE_BLIND
          init_blind_all(:blind)
        when BLIND_MODE_NORMAL
          init_blind_normal
        end

        self
      end

      def init_blind_all(level)
        areas.each do |r|
          r.set_blind(level)
        end

        self
      end

      def init_blind_normal
        rooms.each do |r|
          r.set_blind(:open)
        end

        roads.each do |r|
          r.set_blind(:blind)
        end

        self
      end

      def blind_state(x, y)
        return unless has_xy?(x, y)
        blind_data[x][y]
      end

      def set_blind_state(x, y, state)
        return unless has_xy?(x, y)
        blind_data[x][y] = state
      end

      private

      def blind_data
        @blind_data ||= Hash.new{|hash, key| hash[key] = {}}
        @blind_data
      end

      def fill_dark_before_cancel
        areas.select{|r| r.blind_level_dark?}.each do |r|
          r.each do |x, y|
            blind_data[x][y] = :dark
          end
        end
      end

      def cancel_blind(sx, sy, open_list, range, r=0)
        return unless movable?(sx, sy)
        return if r > range

        # 今のポイントを可視に
        blind_data[sx][sy] = :none

        # 今の座標が:openならareaを可視に
        areas_for(sx, sy).each do |a|
          next unless a.blind_level_open?
          open_list << a unless open_list.include?(a)
        end

        # 再帰的に処理
        Direction.each do |dir|
          nx = sx + dir.x
          ny = sy + dir.y
          cancel_blind(nx, ny, open_list, range, r+1)
        end
      end

    end # Board

  end
end
