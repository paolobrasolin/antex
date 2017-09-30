# frozen_string_literal: true

module Antex
  module LiquidHelpers
    def liquid_render_string(string, context_hash = {})
      Liquid::Template.parse(String(string)).render(context_hash)
    end

    def liquid_render_array(array, context_hash = {})
      Array(array).map do |element|
        liquid_render_string element, context_hash
      end
    end

    def liquid_render_hash(hash, context_hash = {})
      Hash(hash).map do |key, value|
        [key, liquid_render_string(value, context_hash)]
      end.to_h
    end
  end
end
