# frozen_string_literal: true

require 'spec_helper'

describe Antex::TexBox do
  let(:result) { { ten: 10.0, zero: 0.0, pt: 1.0 } }

  describe '#load' do
    subject { described_class.new }

    before do
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with('filename') { <<~YML }
        ten: 10.0pt
        zero: 0.0pt
      YML
    end

    it 'loads measures from a yaml file' do
      expect { subject.load 'filename' }
        .to change { subject.measures }.from({}).to(result)
    end

    it 'sets the default unit to pt' do
      expect { subject.load 'filename' }
        .to change { subject.default_unit }.from(nil).to(:pt)
    end
  end
end
