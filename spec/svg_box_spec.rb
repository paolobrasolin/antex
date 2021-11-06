# frozen_string_literal: true

require 'spec_helper'

describe Antex::SVGBox do
  let(:result) { { ox: 76.71, oy: 55.96, dx: 27.32, dy: 8.949, px: 1.0 } }

  describe '#load' do
    subject { described_class.new }

    before do
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with('filename') { <<~SVG }
        <?xml version='1.0' encoding='UTF-8'?>
        <svg viewBox='76.71 55.96 27.32 8.949'
            width='27.32pt' height='8.94pt'
            version='1.1'
            xmlns='http://www.w3.org/2000/svg'
            xmlns:xlink='http://www.w3.org/1999/xlink'>
        </svg>
      SVG
    end

    it 'loads measures from an svg file' do
      expect { subject.load 'filename' }.
        to change { subject.measures }.from({}).to(result)
    end

    it 'sets the default unit to px' do
      expect { subject.load 'filename' }.
        to change { subject.default_unit }.from(nil).to(:px)
    end
  end
end
