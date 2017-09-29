# coding: utf-8
# frozen_string_literal: true

module Antex
  module Metrics
    class Gauge
      def initialize(yml:, tfm:, fit:, precision: 3)
        @tex = TexBox.new(filename: yml, unit: :ex)
        @tfm = SVGBox.new(filename: tfm, unit: :px)
        @fit = SVGBox.new(filename: fit, unit: :px)
        @precision = precision
        compute_margins
      end

      def render_img_tag(src)
        <<-IMG_TAG.gsub(/(\s\s+)/m, ' ').strip!
        <img style='margin: #{@mt.round(@precision)}ex
                            #{@mr.round(@precision)}ex
                            #{@mb.round(@precision)}ex
                            #{@ml.round(@precision)}ex;
                    height: #{@th.round(@precision)}ex;
                    width: #{@wd.round(@precision)}ex;'
            src='#{src}' />
        IMG_TAG
      end

      private


      #
      #  .--> x     ml    fit.dx     mr
      #  |         |--|-------------|--|
      #  v y
      #         -  ,-------------------.  -
      #      mt |  |        TFM        |  |
      #         -  |  ,-------------.  |  | tfm.dy
      #         |  |  |     FIT     |  |  |
      #         |  |  |             |  |  |
      #  fit.dy |  |  |             |  |  |    r    ,-------.  - tex.ht
      #         |  |  |             |  |  |  <--->  |  TEX  |  |
      #         |  |- |- - - - - - -| -|  |         |- - - -|  -
      #         -  |  `-------------'  |  |         `-------'  - tex.dp
      #      mb |  |                   |  |         |-------|
      #         -  `-------------------'  -           tex.wd
      #
      #            |-------------------|
      #                   tfm.dx
      #

      def compute_margins
        r = (@tex.ht + @tex.dp) / @tfm.dy # [ex/px]
        @th = r * @fit.dy
        @wd = r * @fit.dx
        @ml = r * (- @tfm.ox + @fit.ox)
        @mt = r * (- @tfm.oy + @fit.oy)
        @mr = r * (+ @tfm.dx - @fit.dx) - @ml
        @mb = r * (+ @tfm.dy - @fit.dy) - @mt - @tex.dp
      end
    end
  end
end
