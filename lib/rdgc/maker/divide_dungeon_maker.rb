# coding: UTF-8
module RDGC
  module Maker
    class DivideDungeonMaker
      include DungeonMaker

      def self.create(width, height, params = nil)
        dm = self.new
        list = dm.make(width, height, params)
        Map::Board.create_from_blocks(list)
      end

      DEFAULT_CROSS_ROAD_RATIO = 2

      # override
      def create_whole_block(width, height)
        tb = DivideTempBlock.create_whole_block(width, height)
        tb.min_size = min_block_size
        tb.dividable
        tb
      end

      def make_blocks(tb)
        # 分割キューに最初のBlockを入れる
        divide_queue << tb

        # 再帰分割
        divide

        # 完了キューの中身を返す
        done_queue
      end

      # override
      def create_room
        # 部屋と交差点を分ける
        room_blocks = []
        cross_blocks = []
        force_room_blocks = []

        param = {
          :room => (10 - cross_road_ratio),
          :cross => cross_road_ratio
        }

        blocks.each do |b|
          # 初回分割のBlockは行き止まりになるので避ける
          if b.depth < 2
            force_room_blocks << b
            next
          end

          r = select_rand(param)
          case r
          when :room
            room_blocks << b
          when :cross
            cross_blocks << b
          end
        end

        room_count = room_blocks.size + force_room_blocks.size
        if max_room_count > 0 && room_count > max_room_count
          # 超えた分だけ移動する
          (room_count - max_room_count).times do
            break if room_blocks.size + force_room_blocks.size <= 1
            break if room_blocks.empty?
            b = room_blocks.pickup!
            cross_blocks << b if b
          end
        end

        room_count = room_blocks.size + force_room_blocks.size
        if room_count < min_room_count
          # 足りない分を移動する
          (min_room_count - room_count).times do
            break if cross_blocks.empty?
            b = cross_blocks.pickup!
            room_blocks << b if b
          end
        end

        # それぞれのblockを処理
        [room_blocks, force_room_blocks].flatten.each do |b|
          b.create_room(:min => min_room_size, :max => max_room_size)
        end
        cross_blocks.each{|b| b.create_cross_point}
      end

      # override
      def create_road
        return if blocks.size <= 1

        # 再帰的に道を作成
        recursive_road_create(blocks.choice)

        # 道がない部屋で、既存と接しているところを処理
        connect_cling_block_has_road

        # 道がなく、孤立した部屋を移動
        move_room_and_connect

        # 行き止まりの交差点を処理
        add_road_for_dead_end
      end

      # -------------------------------------------------------------

      def min_block_size
        unless @min_block_size
          val = params[:min_block_size]
          if val
            # 指定がある場合はそれを評価
            val = val.to_i
          else
            # 指定が無く、min_room_sizeが存在するならそちらに合わせる
            val = (min_room_size ? min_room_size + 3 : 0)
          end
          val = Util::Config.min_block_size if val < Util::Config.min_block_size
          @min_block_size = val
        end
        @min_block_size
      end

      def min_room_size
        params[:min_room_size]
      end

      def max_room_size
        params[:max_room_size]
      end

      def max_block_count
        params[:max_block_count].to_i
      end

      def min_room_count
        unless @min_room_count
          val = params[:min_room_count].to_i
          # 明示的に「1」という指定がない限り2部屋は作る
          val = 2 if val <= 0
          @min_room_count = val
        end
        @min_room_count
      end

      def max_room_count
        params[:max_room_count].to_i
      end

      def max_depth
        params[:max_depth].to_i
      end

      def cross_road_ratio
        unless @cross_road_ratio
          val = params[:cross_road_ratio]
          if val
            val = val.to_i
            # 交差点生成率は 1<=x<=9 / 10
            val = DEFAULT_CROSS_ROAD_RATIO if (val < 0 || val > 9)
          else
            # 指定なし => デフォルト
            val = DEFAULT_CROSS_ROAD_RATIO
          end
          @cross_road_ratio = val
        end
        @cross_road_ratio
      end

      def divide_queue
        @divide_queue ||= []
        @divide_queue
      end

      def done_queue
        @done_queue ||= []
        @done_queue
      end

      def queue_size
        divide_queue.size + done_queue.size
      end

      def finish?
        return true if divide_queue.empty?
        return true if (max_block_count > 0 && queue_size >= max_block_count)
        false
      end

      def dividable_block?(b)
        # そもそも分割対象ではない => false
        return false unless b.dividable?

        # 最大深度の指定がない => true
        return true if max_depth <= 0

        # 最大深度に達したら分割しない
        b.depth >= max_depth ? false : true
      end

      def divide
        # 再帰処理
        loop do
          break if finish?

          tb = divide_queue.shift
          break unless tb

          list = tb.divide
          unless list
            # 分割できなかったので、元をdone_queueへ
            done_queue << tb
            break
          end

          list.each do |b|
            if dividable_block?(b)
              divide_queue << b
            else
              done_queue << b
            end
          end
        end

        # queueをまとめる
        divide_queue.each{|b| done_queue << b}
      end

      # -------------------------------------------------------------

      def recursive_road_create(target)
        # 全部道がつながったら終了
        return if blocks.all?{|b| b.has_road?}

        # まだ道の処理をしてない、接しているblockを探す
        yet_block = blocks.reject{|b| b.road_created?}
        cling_list = create_cling_list(target, yet_block)

        # 行き止まり => 終了
        return if cling_list.size <= 0

        # 接しているblockに道を作る
        next_block = connect_cling_blocks(target, cling_list)

        # 作成完了
        target.road_created

        # 次を再帰的呼び出し
        recursive_road_create(next_block)
      end

      def connect_cling_block_has_road
        # 道がない部屋を探す
        remains = blocks.select{|b| b.has_room? && ! b.has_road?}
        return if remains.empty?

        # すでに完了しているblockの数を確認
        done_count = blocks.select{|b| b.has_room? && b.has_road?}.size

        remains.each do |target|
          # min_room_countを満たすならランダム
          if done_count >= min_room_count
            next unless bool_rand
          end

          # 接しているblockに道があるならつなぐ
          c_list = create_cling_list(target, blocks.select{|b| b.has_road?}).flatten
          return if c_list.empty?
          target.create_road_to(c_list.pickup!)
          c_list.each{|b| target.add_remain_cling_blocks(b)}

          done_count += 1
        end
      end

      def move_room_and_connect
        # 完了してしたblockの数を確認し、min_room_countを満たしていたら終わり
        done_count = blocks.select{|b| b.has_room? && b.has_road?}.size
        return if done_count >= min_room_count

        # まだ道がない部屋を探す
        remains = blocks.select{|b| b.has_room? && ! b.has_road?}
        return if remains.empty?

        remains.each do |target|
          # 元の部屋等の削除
          target.remove_all

          # 改めて部屋を作る先を決める
          enable_blocks = blocks.select{|b| b.has_remain_cling_blocks?}
          next if enable_blocks.empty?

          org_block = enable_blocks.choice
          room_block = org_block.remain_cling_blocks.pickup!

          # 部屋作成
          room_block.create_room(:min => min_room_size, :max => max_room_size)

          # 接続
          room_block.create_road_to(org_block)
        end
      end

      def create_cling_list(block, list)
        top_list = collect_cling_block(block, list,:top)
        bottom_list = collect_cling_block(block, list, :bottom)
        left_list = collect_cling_block(block, list, :left)
        right_list = collect_cling_block(block, list, :right)

        [top_list, bottom_list, left_list, right_list].select{|a| a.size > 0}
      end

      def collect_cling_block(block, list, direction)
        case direction
        when :top
          list.select{|b| block.cling_to_top?(b)}
        when :bottom
          list.select{|b| block.cling_to_bottom?(b)}
        when :left
          list.select{|b| block.cling_to_left?(b)}
        when :right
          list.select{|b| block.cling_to_right?(b)}
        end
      end

      def connect_cling_blocks(target, cling_list)
        return unless cling_list
        return if cling_list.size <= 0

        # 4方向で選択可能なblock配列から一つ選ぶ
        direction_list = cling_list.pickup!
        next_block = direction_list.pickup!

        # ブロックに道をつなぐ
        target.create_road_to(next_block)

        # その方向の残りを接しているblockとして記録
        direction_list.each{|b| target.add_remain_cling_blocks(b)}

        # 残りの方向もランダムにつなぐ
        cling_list.each do |d_list|
          bl = d_list.pickup! if bool_rand
          target.create_road_to(bl) if bl
          d_list.each{|b| target.add_remain_cling_blocks(b)}
        end

        # 次の対象返却
        next_block
      end

      def add_road_for_dead_end
        deadends = blocks.select{|b| b.dead_end?}
        return if deadends.empty?

        deadends.each do |target|
          # まだ作成していない方向に何か接しているか？
          c_list = []
          block_list = blocks.select{|b| b.has_road?}
          target.remain_direction.each do |d|
            ret = collect_cling_block(target, block_list, d)
            c_list += ret.flatten
          end
          next if c_list.empty?
          target.create_road_to(c_list.pickup!)
        end
      end

    end
  end
end
