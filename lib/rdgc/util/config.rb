# coding: UTF-8
module RDGC
  module Util
    class Config

      DEFAULT_CONFIG = {
        :min_room_size => 4,
        :act_max_count => 200
      }

      self.class.class_eval do
        @config_hash = DEFAULT_CONFIG
      end

      def self.set(hash)
        return if seted?

        default = nil
        self.class.class_eval do
          default = @config_hash
        end

        hash = default.merge(hash)

        self.class.class_eval do
          @config_hash = hash
          @seted = true
        end

        true
      end

      def self.min_room_size
        self.get(:min_room_size)
      end

      def self.min_block_size
        # デフォルトのblock最小値 = 最小部屋サイズ+上下空き2+接線通路分1
        self.min_room_size + 3
      end

      def self.act_max_count
        self.get(:act_max_count)
      end

      def self.seted?
        ret = false
        self.class.class_eval do
          ret = @seted
        end
        ret
      end

      def self.get(key)
        val = nil
        self.class.class_eval do
          val = @config_hash[key]
        end
        val
      end

      def self.reset!
        self.class.class_eval do
          @config_hash = DEFAULT_CONFIG
          @seted = false
        end

        true
      end

    end
  end
end

