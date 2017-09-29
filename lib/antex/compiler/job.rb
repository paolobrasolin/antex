# frozen_string_literal: true

module Antex
  module Compiler
    class Job
      attr_accessor :options, :hash # TODO: drop

      def initialize(snippet: '', options: {})
        @options = options
        @snippet = snippet
      end

      def run
        make_dirs
        prepare_code
        run_pipeline
        filehash = %i[yml tfm fit].map { |sym| [sym, file(sym)] }.to_h
        @gauge = SetBox.new.load filehash
      end

      # def add_to_static_files_of(site)
      #   FileUtils.cp(file(:fit), file(:svg))
      #   # TODO: minify/compress svg?
      #   site.static_files << Jekyll::StaticFile.new(
      #     site, dir(:work), @options['dest_dir'], "#{@hash}.svg"
      #   )
      # end

      def html_tag
        img_tag = @gauge.render_img_tag("/#{@options['dest_dir']}/#{@hash}.svg")
        classes = @options['classes'].join(' ')
        "<span class='#{classes}'>#{img_tag}</span>"
      end

      # private

      def make_dirs
        FileUtils.mkdir_p dir(:work)
        FileUtils.mkdir_p "#{dir(:work)}/#{@options['dest_dir']}"
      end

      def prepare_code
        template = Liquid::Template.parse(@options['template'])
        @code = template.render(
          'preamble' => @options['preamble'],
          'append' => @options['append'],
          'prepend' => @options['prepend'],
          'snippet' => @snippet
        )
        @hash = Digest::MD5.hexdigest(@code)

        unless File.exist?(file(:tex))
          File.open(file(:tex), 'w') do |file|
            file.write(@code)
          end
        end
      end

      def run_pipeline
        Pipeline.new(
          pipeline: @options['pipeline'],
          engines: @options['engines'],
          context: binding
        ).run
      end

      def dir(key)
        { work: @options['work_dir'] }[key]
      end

      def file(key)
        dir(:work) + {
          tex: "/#{@hash}.tex",
          dvi: "/#{@hash}.dvi",
          yml: "/#{@hash}.yml",
          tfm: "/#{@hash}.tfm.svg",
          fit: "/#{@hash}.fit.svg",
          svg: "/#{@options['dest_dir']}/#{@hash}.svg"
        }[key]
      end
    end
  end
end
