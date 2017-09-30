# frozen_string_literal: true

require 'nokogiri'

module Antex
  # Loads and manages measures for +SVG+ pictures.
  class SVGBox < Measurable
    # Loads an +SVG+ file and extracts the measures of its +viewBox+.
    #
    # @param filepath [String] the path of the SVG file to load
    # @return [SVGBox] returns self after loading
    def load(filepath)
      svg_ast = Nokogiri::XML.parse File.read(filepath)
      view_box = svg_ast.css('svg').attribute('viewBox')
      magnitudes = view_box.to_s.split(' ').map(&:to_f)
      @measures = %i[ox oy dx dy].zip(magnitudes).to_h
      @measures[:px] ||= 1.0
      @default_unit = :px
      self
    end
  end
end
