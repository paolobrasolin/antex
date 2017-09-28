# frozen_string_literal: true

require 'nokogiri'

module Antex
  class SVGBox < Measurable
    def load(filename)
      svg_ast = Nokogiri::XML.parse File.read(filename)
      view_box = svg_ast.css('svg').attribute('viewBox')
      magnitudes = view_box.to_s.split(' ').map(&:to_f)
      @measures = %i[ox oy dx dy].zip(magnitudes).to_h
      @measures[:px] ||= 1.0
      @default_unit = :px
      self
    end
  end
end
