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
      # TODO: prevent division by zero in smart way
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
