# frozen_string_literal: true

require 'yaml'

module Antex
  # Loads and manages measures for +TeX+ boxes.
  class TexBox < Measurable
    # Loads a +YAML+ file containing +TeX+ measures.
    #
    # The expected input is a hash of named +pt+ lenghts.
    # E.g.:
    #
    #   pt: 1.0pt
    #   wd: 5.0pt
    #   ht: 8.0pt
    #   dp: 2.0pt
    #
    # @param filepath [String] the path of the YAML file to load
    # @return [TexBox] returns +self+ after loading
    def load(filepath)
      yaml_hash = YAML.safe_load File.read(filepath)
      units = yaml_hash.keys.map(&:to_sym)
      magnitudes = yaml_hash.values.map { |value| value.chomp('pt').to_f }
      @measures = units.zip(magnitudes).to_h
      @measures[:pt] ||= 1.0
      @default_unit = :pt
      self
    end
  end
end
