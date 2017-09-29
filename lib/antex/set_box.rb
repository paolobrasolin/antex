# coding: utf-8
# frozen_string_literal: true

module Antex
  class SetBox < Measurable
    def load(yml:, tfm:, fit:)
      @tex = TexBox.new.load yml
      @tfm = SVGBox.new.load tfm
      @fit = SVGBox.new.load fit
      @tex.default_unit = :ex
      self.measures = compute_measures
      self.default_unit = :ex
      self
    end

    # This should not be here, methinks.
    def render_img_tag(src, precision: 3)
      <<~IMG_TAG.gsub(/(\s\s+)/m, ' ').strip!
        <img style='margin: #{mt.round(precision)}ex
                            #{mr.round(precision)}ex
                            #{mb.round(precision)}ex
                            #{ml.round(precision)}ex;
                    height: #{th.round(precision)}ex;
                    width:  #{wd.round(precision)}ex;'
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
  end
end
