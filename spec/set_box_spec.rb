# frozen_string_literal: true

require 'spec_helper'

describe Antex::SetBox do
  let(:result) do
    { ex: 1, th: 6.0, wd: 10.5, ml: 0.5, mt: 1.0, mr: -1.0, mb: -3.0 }
  end

  describe '#load' do
    subject { described_class.new }

    before do
      allow(File).to receive(:read).and_call_original

      allow(File).to receive(:read).with('tex.yml') { <<~TEX_YML }
        pt: 1.0pt
        ex: 2.0pt
        ht: 8.0pt
        dp: 2.0pt
        wd: 20.0pt
      TEX_YML

      allow(File).to receive(:read).with('tfm.svg') { <<~TFM_SVG }
        <?xml version='1.0' encoding='UTF-8'?>
        <svg viewBox='0.0 0.0 200.0 100.0'
            width='200.0pt' height='100.0pt'
            version='1.1'
            xmlns='http://www.w3.org/2000/svg'
            xmlns:xlink='http://www.w3.org/1999/xlink'>
        </svg>
      TFM_SVG

      allow(File).to receive(:read).with('fit.svg') { <<~FIT_SVG }
        <?xml version='1.0' encoding='UTF-8'?>
        <svg viewBox='10.0 20.0 210.0 120.0'
            width='200.0pt' height='100.0pt'
            version='1.1'
            xmlns='http://www.w3.org/2000/svg'
            xmlns:xlink='http://www.w3.org/1999/xlink'>
        </svg>
      FIT_SVG
    end

    it 'loads measures from an svg file' do
      expect { subject.load yml: 'tex.yml', tfm: 'tfm.svg', fit: 'fit.svg' }
        .to change { subject.measures }.from({}).to(result)
    end
  end
end
