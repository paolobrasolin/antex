# frozen_string_literal: true

module Antex
  module Metrics
    class Set
      attr_reader :unit, :metrics

      def initialize(filename: nil, unit: nil)
        @metrics = {}
        load filename unless filename.nil?
        self.unit = unit unless unit.nil?
      end

      attr_writer :unit

      private

      def calc(metric, unit = @unit)
        raise "Invalid metric: #{metric} is undefined." unless @metrics.key? metric
        raise 'Invalid unit: default is not set.' if unit.nil?
        raise "Invalid unit: #{unit} is undefined." unless @metrics.key? unit
        raise "Invalid unit: #{unit} is zero." if @metrics[unit].zero?
        @metrics[metric] / @metrics[unit]
      end

      def respond_to_missing?(method_name, include_private = false)
        (@metrics.include? method_name) || super
      end

      def method_missing(method_name, *arguments, &block)
        if @metrics.include? method_name
          send(:calc, method_name, *arguments, &block)
        else
          super
        end
      end
    end
  end
end
