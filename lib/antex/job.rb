# frozen_string_literal: true

module Antex
  class Job
    attr_reader :options, :hash

    attr_reader :set_box

    def initialize(snippet: '', options: {})
      @options = options
      @snippet = snippet
    end

    def run
      prepare_dirs
      prepare_code
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
      @dirs ||= {
        work: @options['work_dir']
      }

      @dirs[key]
    end

    def file(key)
      @files ||= {
        tex: File.join(@options['work_dir'], "#{@hash}.tex"),
        dvi: File.join(@options['work_dir'], "#{@hash}.dvi"),
        yml: File.join(@options['work_dir'], "#{@hash}.yml"),
        tfm: File.join(@options['work_dir'], "#{@hash}.tfm.svg"),
        fit: File.join(@options['work_dir'], "#{@hash}.fit.svg"),
        svg: File.join(@options['work_dir'], "#{@hash}.svg")
      }

      @files[key]
    end

    private

    def prepare_dirs
      FileUtils.mkdir_p dir(:work)
    end

    def prepare_code
      template = Liquid::Template.parse @options['template']

      @code = template.render(
        'preamble' => @options['preamble'],
        'append'   => @options['append'],
        'prepend'  => @options['prepend'],
        'snippet'  => @snippet
      )

      @hash = Digest::MD5.hexdigest @code

      return if File.exist? file(:tex)
      File.open(file(:tex), 'w') { |file| file.write @code }
    end

    def run_pipeline
      Pipeline.new(
        pipeline: @options['pipeline'],
        commands: @options['commands'],
        binding: binding
      ).run
    end

    def load_set_box
      @set_box = SetBox.new.load yml: file(:yml),
                                 tfm: file(:tfm),
                                 fit: file(:fit)
    end
  end
end
