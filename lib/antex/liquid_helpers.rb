# frozen_string_literal: true

require 'liquid'

module Antex
  # Exposes helper methods to simplify +Liquid+ templates rendering.
  module LiquidHelpers
    class UnknownClass < Error; end

    # Recursively renders +Liquid+ template strings, possibly organized in
    # nested arrays and hashes, using the given hash of contextual variables.
    #
    # @param object [String, Array, Hash] the object to render
    # @param context_hash [Hash]
    #   the context hash accessible from the object strings
    # @return [String] the rendered object
    # @raise [UnknownClass] when given anything that's not renderable
    def liquid_render(object, context_hash = {})
      case object
      when String
        liquid_render_string object, context_hash
      when Array
        liquid_render_array object, context_hash
      when Hash
        liquid_render_hash object, context_hash
      else
        raise UnknownClass, "I don't know how to render a #{object.class}."
      end
    end

    private

    def liquid_render_string(string, context_hash = {})
      Liquid::Template.parse(string).render(context_hash)
    end

    def liquid_render_array(array, context_hash = {})
      array.map do |element|
        liquid_render element, context_hash
      end
    end

    def liquid_render_hash(hash, context_hash = {})
      hash.transform_values do |value|
        liquid_render(value, context_hash)
      end
    end
  end
end
