# frozen_string_literal: true

module Antex
  class Job
    include LiquidHelpers

    attr_reader :options, :dirs, :files, :hash, :set_box

    def initialize(snippet: '', options: {})
      @options = options
      @snippet = snippet
    end

    def run
      prepare_code
      prepare_hash

      prepare_dirs
      prepare_files

      write_code

      run_pipeline!
      load_set_box
    end

    # TODO: should be in jekyll-antex
    def html_tag
      img_tag = @set_box.render_img_tag("/#{@options['work_dir']}/#{@hash}.svg")
      classes = @options['classes'].join(' ')
      "<span class='#{classes}'>#{img_tag}</span>"
    end

    private

    def prepare_code
      @code = liquid_render @options['template'],
                            'preamble' => @options['preamble'],
                            'append'   => @options['append'],
                            'prepend'  => @options['prepend'],
                            'snippet'  => @snippet
    end

    def prepare_hash
      @hash = Digest::MD5.hexdigest @code
    end

    def prepare_dirs
      @dirs = liquid_render @options['dirs'],
                            'hash' => @hash
      @dirs.each_value { |path| FileUtils.mkdir_p path }
    end

    def prepare_files
      @files = liquid_render @options['files'],
                             'hash' => @hash,
                             'dir' => @dirs
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
        Command.new(options).run!
      end
    end

    def load_set_box
      @set_box = SetBox.new.load yml: @files['yml'],
                                 tfm: @files['tfm'],
                                 fit: @files['fit']
    end
  end
end
