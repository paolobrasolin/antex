# frozen_string_literal: true

require 'spec_helper'

describe Antex::Metrics::TeXBox do
  let(:data) { { true_metric: '10.0pt', zero_metric: '0.0pt' } }
  let(:result) { { true_metric: 10.0, zero_metric: 0.0, pt: 1.0 } }

  describe 'initializing with no options' do
    let(:box) { Antex::Metrics::TeXBox.new }

    it 'has no metrics' do
      expect(box.metrics).to be_empty
    end

    it 'has no unit' do
      expect(box.unit).to be_nil
    end

    it 'can load a file' do
      expect(YAML).to receive(:load_file).with('filename') { data }
      box.load 'filename'
      expect(box.metrics).to be == result
    end
  end

  describe '.load_yml' do
    context 'when initialized with a file' do
      before { allow(YAML).to receive(:load_file).with('filename') { data } }
      let(:box) { Antex::Metrics::TeXBox.new(filename: 'filename') }

      it 'contains the trivial metric' do
        box.unit = :true_metric
        expect(box.true_metric).to equal(1.0)
      end

      it 'cannot reach undefined metrics' do
        expect { box.fake_metric }.to raise_error NoMethodError
      end

      it 'cannot use default unit if not set' do
        expect { box.true_metric }.to raise_error RuntimeError, /not set/i
      end

      it 'cannot use undefined metrics as units' do
        expect { box.true_metric :fake_metric }.to raise_error RuntimeError, /undefined/i
      end

      it 'cannot use a metric with value zero as unit' do
        expect { box.true_metric :zero_metric }.to raise_error RuntimeError, /zero/i
      end

      it 'cannot' do
        expect(box.true_metric(:true_metric)).to equal 1.0
      end
    end
  end
end
