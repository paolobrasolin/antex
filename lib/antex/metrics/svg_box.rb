# frozen_string_literal: true

require 'nokogiri'

module Antex
  module Metrics
    class SVGBox < Set
      private

      def load(filename)
        svg_ast = Nokogiri::XML.parse(File.read(filename))
        view_box = svg_ast.css('svg').attribute('viewBox')
        ox, oy, dx, dy = view_box.to_s.split(' ').map(&:to_f)
        @metrics = { ox: ox, oy: oy, dx: dx, dy: dy }
        @metrics[:px] ||= 1.0
        @metrics
      end
    end
  end
end
