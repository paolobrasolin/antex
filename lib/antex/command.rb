# frozen_string_literal: true

require 'open3'

module Antex
  # This class encapsulates the execution of a command line that needs
  # some source files to produce some target files.
  #
  # Existence checks are performed on files:
  # * if all targets exist before execution then it is skipped
  # * all sources must exist before execution
  # * all targets must exist after execution
  #
  # Details of the execution itself are given by
  # the attributes {#stdout}, {#stderr} and {#status}.
  class Command
    class MissingSourceFiles < Error; end

    class MissingTargetFiles < Error; end

    class ExecutionFailed < Error; end

    # @return [String, nil] the +stdout+ returned by the command line
    attr_reader :stdout

    # @return [String, nil] the +stderr+ returned by the command line
    attr_reader :stderr

    # @return [Process::Status, nil] the +status+ returned by the command line
    attr_reader :status

    # Initializes the command.
    #
    # @note A command with no targets will always skip
    #   since it needs to produce nothing!
    #
    # @param name [String] name of the command (just for error reporting)
    # @param sources [Array] list of source files
    # @param targets [Array] list of target files
    # @param command_line [String] command line that will be executed
    def initialize(name:, sources:, targets:, command_line:)
      @name = name
      @sources = sources
      @targets = targets
      @command_line = command_line
    end

    # Executes the command.
    #
    # @raise [MissingSourceFiles] when source files are missing
    # @raise [ExecutionFailed] when command execution fails
    # @raise [MissingTargetFiles] when command does not create target files
    def run!
      return if all_exist? @targets

      check_source_files!
      @stdout, @stderr, @status = Open3.capture3 @command_line
      check_status!
      check_target_files!
    end

    private

    def all_exist?(files)
      files.all?(&File.method(:exist?))
    end

    def missing(files)
      files.reject(&File.method(:exist?))
    end

    def check_source_files!
      raise MissingSourceFiles, <<~MISSING_SOURCE unless all_exist? @sources
        Required source files #{missing @sources} for command #{@name} are missing.
      MISSING_SOURCE
    end

    def check_status!
      raise ExecutionFailed, <<~EXECUTION_FAILED unless @status.success?
        Command #{@name} failed.
        Command line: #{@command_line}
        Status: #{@status}
        Stdout:
        #{@stdout}
        Stderr:
        #{@stderr}
      EXECUTION_FAILED
    end

    def check_target_files!
      raise MissingTargetFiles, <<~MISSING_TARGET unless all_exist? @targets
        Expected target files #{missing @targets} were not produced by command #{@name}.
      MISSING_TARGET
    end
  end
end
