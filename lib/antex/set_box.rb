# frozen_string_literal: true

module Antex
  # Encapsulates calculations and results for perfectly typesetting
  # the +SVG+ vectorial conversion of a +TeX+ box.
  #
  # Three files are required by {#load} for initialization:
  # [+YAML+ file containing +TeX+ measures]
  #   We obtain this by using +TeX+ directly to measure the box and write to file.
  #   Required metrics are +ht+, +dp+ and +wd+ (naturally expressed in +pt+s).
  # [+SVG+ picture fitting +tfm+ metrics]
  #   We obtain this by converting the +DVI+ rendition of the box
  #   to +SVG+ using {http://dvisvgm.bplaced.net/ +dvisvgm+}.
  # [+SVG+ picture fitting the ink]
  #   We obtain this by converting the +DVI+ rendition of the box
  #   to +SVG+ using {http://dvisvgm.bplaced.net/ +dvisvgm+}
  #   with the +--exact+ flag.
  #
  # After the initialization the calculations are performed immediatly.
  # Six metrics become available:
  # * +mt+, +mr+, +ml+ and +ml+ (the margins, positive or negative)
  # * +wd+ and +ht+ (width and height)
  # * +ex+ (the default unit)
  class SetBox < Measurable
    class InvalidMeasure < Antex::Error; end

    # @param yml [String] path of the +YAML+ file containing +TeX+ measures
    # @param tfm [String] path of the +SVG+ picture fitting +tfm+ metrics
    # @param fit [String] path of the +SVG+ picture fitting the ink
    # @return [TexBox] returns +self+ after loading
    def load(yml:, tfm:, fit:)
      @tex = TexBox.new.load yml
      @tfm = SVGBox.new.load tfm
      @fit = SVGBox.new.load fit
      @tex.default_unit = :ex
      check_measures!
      self.measures = compute_measures
      self.default_unit = :ex
      self
    end

    private

    # Memorandum:
    #   .--> x     ml    fit.dx     mr
    #   |         |--|-------------|--|
    #   v y
    #          -  ,-------------------.  -
    #       mt |  |        TFM        |  |
    #          -  |  ,-------------.  |  | tfm.dy
    #          |  |  |     FIT     |  |  |
    #          |  |  |             |  |  |
    #   fit.dy |  |  |             |  |  |    r    ,-------.  - tex.ht
    #          |  |  |             |  |  |  <--->  |  TEX  |  |
    #          |  |- |- - - - - - -| -|  |         |- - - -|  -
    #          -  |  `-------------'  |  |         `-------'  - tex.dp
    #       mb |  |                   |  |         |-------|
    #          -  `-------------------'  -           tex.wd
    #             |-------------------|
    #                    tfm.dx
    def compute_measures # rubocop:disable Metrics/AbcSize
      ex_px = (@tex.ht + @tex.dp) / @tfm.dy # [ex/px]
      {
        ex: 1,
        th: ex_px * @fit.dy,
        wd: ex_px * @fit.dx,
        ml: ex_px * (- @tfm.ox + @fit.ox),
        mt: ex_px * (- @tfm.oy + @fit.oy),
        mr: ex_px * (+ @tfm.ox - @fit.ox + @tfm.dx - @fit.dx),
        mb: ex_px * (+ @tfm.oy - @fit.oy + @tfm.dy - @fit.dy) - @tex.dp
      }
    end

    def check_measures!
      raise InvalidMeasure, <<~INVALID_MEASURE if @tfm.dy.zero?
        The given tfm SVG file has zero height.
      INVALID_MEASURE
    end
  end
end
