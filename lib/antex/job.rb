# frozen_string_literal: true

module Antex
  class Job
    include LiquidHelpers

    attr_reader :options, :hash

    attr_reader :set_box

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
      run_pipeline
      load_set_box
    end

    # TODO: should be in jekyll-antex
    def html_tag
      img_tag = @set_box.render_img_tag("/#{@options['work_dir']}/#{@hash}.svg")
      classes = @options['classes'].join(' ')
      "<span class='#{classes}'>#{img_tag}</span>"
    end

    def dir(key)
      @dirs[key.to_s]
    end

    def file(key)
      @files[key.to_s]
    end

    private

    def prepare_code
      @code = liquid_render_string @options['template'],
                                   'preamble' => @options['preamble'],
                                   'append'   => @options['append'],
                                   'prepend'  => @options['prepend'],
                                   'snippet'  => @snippet
    end

    def prepare_hash
      @hash = Digest::MD5.hexdigest @code
    end

    def prepare_dirs
      @dirs = liquid_render_hash @options['dirs'],
                                 'hash' => @hash
      @dirs.each_value { |path| FileUtils.mkdir_p path }
    end

    def prepare_files
      @files = liquid_render_hash @options['files'],
                                  'dir' => @dirs,
                                  'hash' => @hash
    end

    def write_code
      return if File.exist? @files['tex']
      File.open(@files['tex'], 'w') { |io| io.write @code }
    end

    def run_pipeline
      Pipeline.new(
        pipeline: @options['pipeline'],
        commands: @options['commands'],
        binding: { 'dir' => @dirs, 'file' => @files, 'hash' => @hash }
      ).run
    end

    def load_set_box
      @set_box = SetBox.new.load yml: file(:yml),
                                 tfm: file(:tfm),
                                 fit: file(:fit)
    end
  end
end
