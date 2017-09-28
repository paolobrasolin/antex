# frozen_string_literal: true

require 'yaml'

module Antex
  class TexBox < Measurable
    def load(filename)
      yaml_hash = YAML.safe_load File.read(filename)
      units = yaml_hash.keys.map(&:to_sym)
      magnitudes = yaml_hash.values.map { |value| value.chomp('pt').to_f }
      @measures = units.zip(magnitudes).to_h
      @measures[:pt] ||= 1.0
      @default_unit = :pt
      self
    end
  end
end
