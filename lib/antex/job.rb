# frozen_string_literal: true

module Antex
  # This class is the beating heart of {Antex}.
  #
  # The simplest usage of this gem involves three steps:
  #   # 1. Get a LaTeX snippet and initialize a job.
  #   job = Antex::Job.new snippet: "Hello, \TeX world!"
  #   # 2. Run the job!
  #   job.run!
  #   # 3. Do something neat with your new SVG file and its typesetting metrics.
  #   job.files(:svg) # => "./.antex-cache/eb64793dafe3bbd963dc663385a22096.svg"
  #   job.set_box.measures # => {:ex=>1, :wd=>17.03..., :mt=>-0.05..., ...}
  #
  # The {Antex::Job::DEFAULTS} are tuned to work with a basic
  # +latexmk+/+dvisvgm+ pipeline.
  # To get started with customization. you'll want to read the (not yet well
  # documented) +YAML+ source loaded into the constant at the
  # {https://github.com/paolobrasolin/antex/blob/master/lib/antex/defaults.yml
  # github repo}.
  class Job
    include LiquidHelpers

    # The configuration defaults for a +latexmk+/+dvisvgm+ pipeline.
    DEFAULTS =
      YAML.load_file(File.join(File.dirname(__FILE__), 'defaults.yml')).freeze

    # @return [Hash] the initialization options
    attr_reader :options

    # @return [Hash] the dirs paths rendered from the options
    attr_reader :dirs

    # @return [Hash] the files paths rendered from the options
    attr_reader :files

    # @return [String] the unique hash identifying the job
    attr_reader :hash

    # @return [SetBox, nil] the {SetBox} calculated by the {#run!}
    attr_reader :set_box

    # @param snippet [String] +TeX+ code snippet to render
    # @param options [Hash] job options
    def initialize(snippet: '', options: Antex::Job::DEFAULTS)
      @options = options
      @snippet = snippet

      prepare_code
      prepare_hash
      prepare_dirs
      prepare_files
    end

    # Run the job, compile the +TeX+ snippet and calculate the {#set_box}.
    def run!
      create_dirs
      write_code
      run_pipeline!
      load_set_box
    end

    private

    def prepare_code
      @code = liquid_render @options['template'],
                            'preamble' => @options['preamble'],
                            'append' => @options['append'],
                            'prepend' => @options['prepend'],
                            'snippet' => @snippet
    end

    def prepare_hash
      @hash = Digest::MD5.hexdigest @code
    end

    def prepare_dirs
      @dirs = liquid_render @options['dirs'],
                            'hash' => @hash
    end

    def prepare_files
      @files = liquid_render @options['files'],
                             'hash' => @hash,
                             'dir' => @dirs
    end

    def create_dirs
      @dirs.each_value { |path| FileUtils.mkdir_p path }
    end

    def write_code
      return if File.exist? @files['tex']

      File.open(@files['tex'], 'w') { |io| io.write @code }
    end

    def run_pipeline!
      context = { 'hash' => @hash, 'dir' => @dirs, 'file' => @files }
      pipeline = liquid_render @options['pipeline'], context
      commands = liquid_render @options['commands'], context

      pipeline.each do |command_name|
        options = { name: command_name,
                    sources: commands[command_name]['sources'],
                    targets: commands[command_name]['targets'],
                    command_line: commands[command_name]['command'].join(' ') }
        Command.new(**options).run!
      end
    end

    def load_set_box
      @set_box = SetBox.new.load yml: @files['yml'],
                                 tfm: @files['tfm'],
                                 fit: @files['fit']
    end
  end
end
