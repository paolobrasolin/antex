# frozen_string_literal: true

require 'yaml'

module Antex
  module Metrics
    class TeXBox < Set
      private

      def load(filename)
        @metrics = Hash[
          YAML.load_file(filename).map do |(key, value)|
            [key.to_sym, value.chomp('pt').to_f]
          end
        ]
        @metrics[:pt] ||= 1.0
        @metrics
      end
    end
  end
end
