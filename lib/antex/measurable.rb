# frozen_string_literal: true

module Antex
  # Implements an easy to use container for storing measures
  # and retrieving them performing unit conversions.
  #
  # Measures should be a hash with symbolic keys
  # and numeric values with uniform units.
  #   mea = Measurable.new
  #   mea.measures = { km: 1, mi: 0.621 }
  class Measurable
    class InvalidUnit < Antex::Error; end

    def initialize
      @default_unit = nil
      @measures = {}
    end

    # @return [Symbol] the default unit
    attr_reader :default_unit

    def default_unit=(unit)
      raise InvalidUnit, "Unit #{unit} is undefined." unless @measures.key? unit
      raise InvalidUnit, "Unit #{unit} is zero." if @measures[unit].zero?

      @default_unit = unit
    end

    # @return [Hash] the stored measures
    # @note When setting, the default unit will be set to +nil+.
    attr_reader :measures

    def measures=(measures)
      @default_unit = nil
      @measures = measures
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

    # Once measures are set they can be accessed and converted.
    #   mea.km(:km) # => 1.0
    #   mea.km(:mi) # => 1.610...
    #   mea.mi(:mi) # => 1.0
    #   mea.mi(:km) # => 0.621
    #
    # You can set a default unit for quicker access.
    #   mea.default_unit = :mi
    #   mea.km # => 1.610...
    #   mea.mi # => 1.0
    def method_missing(method_name, *arguments, &block)
      return super unless @measures.include? method_name

      send :calculate, method_name, *arguments, &block
    end
  end
end
