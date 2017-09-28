# frozen_string_literal: true

module Antex
  class Measurable
    class InvalidUnit < Antex::Error; end

    attr_reader :default_unit, :measures

    def initialize
      self.measures = {}
    end

    def default_unit=(unit)
      raise InvalidUnit, "Unit #{unit} is undefined." unless @measures.key? unit
      raise InvalidUnit, "Unit #{unit} is zero." if @measures[unit].zero?
      @default_unit = unit
    end

    def measures=(**measures)
      @measures = measures
      @default_unit = nil
    end

    private

    def calculate(metric, unit = @default_unit)
      raise InvalidUnit, 'Default unit is not set.' if unit.nil?
      raise InvalidUnit, "Unit #{unit} is undefined." unless @measures.key? unit
      raise InvalidUnit, "Unit #{unit} is zero." if @measures[unit].zero?
      @measures[metric].fdiv @measures[unit]
    end

    def respond_to_missing?(method_name, include_private = false)
      (@measures.include? method_name) || super
    end

    def method_missing(method_name, *arguments, &block)
      if @measures.key? method_name
        send(:calculate, method_name, *arguments, &block)
      else
        super
      end
    end
  end
end
