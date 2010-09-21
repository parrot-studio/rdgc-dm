# coding: UTF-8
module RDGC
  module Util
    class Config

      DEFAULT_CONFIG = {
        :min_room_size => 4
      }

      class << self

        def set(hash)
          return if seted?

          hash = DEFAULT_CONFIG.merge(hash)
          @config_hash = hash
          @seted = true

          true
        end

        def get(key)
          @config_hash ||= DEFAULT_CONFIG
          @config_hash[key]
        end

        def seted?
          @seted ? true : false
        end

        def reset!
          @config_hash = DEFAULT_CONFIG
          @seted = false
          true
        end

        def min_room_size
          get(:min_room_size)
        end

        def min_block_size
          # デフォルトのblock最小値 = 最小部屋サイズ+上下空き2+接線通路分1
          min_room_size + 3
        end

      end

    end
  end
end

