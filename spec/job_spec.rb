# frozen_string_literal: true

require 'spec_helper'

describe Antex::Job do
  let(:tmpdir) { File.join Dir.tmpdir, 'antex-tests' }

  before(:each) do
    FileUtils.rm_rf tmpdir
    FileUtils.mkdir_p tmpdir
  end

  after(:each) do
    FileUtils.rm_rf tmpdir
  end

  describe '.new' do
    let(:options) do
      Antex::Job::DEFAULTS.dup.merge YAML.safe_load(<<~YML)
        dirs:
          work: #{File.join tmpdir, '.antex-cache'}
      YML
    end

    subject { described_class.new snippet: 'Hello, world!', options: options }

    it 'runs smoothly' do
      expect { subject.run! }.to_not raise_exception
    end
  end
end
