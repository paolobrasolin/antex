# frozen_string_literal: true

require 'open3'
require 'erb'

module Antex
  module Compiler
    class Pipeline
      def initialize(pipeline:, engines:, context:)
        @pipeline = pipeline
        @engines = engines
        @binding = context
      end

      def run
        @pipeline.each do |engine|
          run_engine(@engines[engine])
        end
      end

      private

      def file_list_exists(list)
        list.map { |file| File.exist?(file) }.reduce(:&)
      end

      def erb_render_array(array)
        Array(array).map do |element|
          ERB.new(element).result(@binding)
        end
      end

      def run_engine(engine)
        # Skip if targets exist.
        targets = erb_render_array(engine['targets'])
        return if file_list_exists(targets)
        # Raise if sources are missing.
        sources = erb_render_array(engine['sources'])
        raise 'Missing source files!' unless file_list_exists(sources)
        # Execute command.
        command = erb_render_array(engine['command']).join(' ')
        _stdout, _stderr, status = Open3.capture3(command)
        # Raise if unsuccesful or ineffective.
        raise 'Execution error!' + _stdout unless status.success?
        raise 'Targets not produced!' unless file_list_exists(targets)
      end
    end
  end
end
