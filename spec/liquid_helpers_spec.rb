# frozen_string_literal: true

require 'spec_helper'

describe Antex::LiquidHelpers do
  context 'model is included in an instantiated class' do
    subject { Class.new { include Antex::LiquidHelpers }.new }

    describe '#liquid_render' do
      let(:context) do
        { 'foo' => 'FOO', 'bar' => { 'qux' => 'QUX', 'zot' => 'ZOT' } }
      end

      it 'renders a simple string' do
        expect(subject.liquid_render('abc')).to eq 'abc'
      end

      it 'interpolates context values' do
        expect(subject.liquid_render('abc{{ foo }}xyz', context))
          .to eq 'abcFOOxyz'
      end

      it 'interpolates context hashes' do
        expect(subject.liquid_render('abc{{ bar.qux }}xyz', context))
          .to eq 'abcQUXxyz'
      end

      it 'renders an array' do
        expect(subject.liquid_render(['abc', '{{ foo }}'], context))
          .to eq %w[abc FOO]
      end

      it 'renders an hash' do
        input = { a: 'abc', b: '{{ foo }}' }
        output = { a: 'abc', b: 'FOO' }
        expect(subject.liquid_render(input, context)).to eq output
      end

      it 'renders a complex nesting' do
        input = {
          a: 'abc', b: '{{ foo }}',
          c: ['{{ bar.qux }}', { z: '{{ bar.zot }}' }]
        }
        output = { a: 'abc', b: 'FOO', c: ['QUX', { z: 'ZOT' }] }
        expect(subject.liquid_render(input, context)).to eq output
      end

      it 'raises an error if given weird objects' do
        expect { subject.liquid_render(123) }
          .to raise_exception Antex::LiquidHelpers::UnknownClass
      end
    end
  end
end
