# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

describe Antex::Command do
  let(:tmpdir) { File.join Dir.tmpdir, 'antex_tests' }

  before(:each) do
    FileUtils.rm_rf tmpdir
    FileUtils.mkdir_p tmpdir
  end

  after(:each) do
    FileUtils.rm_rf tmpdir
  end

  describe 'trivial command' do
    subject do
      described_class.new name: 'foobar',
                          sources: [],
                          targets: [],
                          command_line: 'foobar'
    end

    it 'skips since noo targets are given' do
      expect { subject.run! }
        .to_not change { subject.status&.exited? }.from(nil)
    end
  end

  describe 'simplest command' do
    let(:hello_world) { File.join tmpdir, 'hello_world' }

    subject do
      described_class.new name: 'touch',
                          sources: [],
                          targets: [hello_world],
                          command_line: "touch #{hello_world}"
    end

    it 'runs silently' do
      expect { subject.run! }.to_not raise_exception
    end

    it 'runs effectively' do
      expect { subject.run! }
        .to change { subject.status&.exited? }.from(nil).to(true)
    end
  end

  describe 'sources checking (pre)' do
    let(:sources) { %w[source_a source_b].map { |fn| File.join tmpdir, fn } }
    let(:target) { File.join tmpdir, 'target' }

    subject do
      described_class.new name: 'touch',
                          sources: sources,
                          targets: [target],
                          command_line: "touch #{target}"
    end

    it 'raises if no sources exist' do
      expect { subject.run! }
        .to raise_exception Antex::Command::MissingSourceFiles
    end

    it 'raises if some sources exist' do
      `touch #{sources[0]}`

      expect { subject.run! }
        .to raise_exception Antex::Command::MissingSourceFiles
    end

    it 'runs if all sources exist' do
      `touch #{sources.join ' '}`

      expect { subject.run! }
        .to change { subject.status&.exited? }.from(nil).to(true)
    end
  end

  describe 'targets checking (pre)' do
    let(:targets) { %w[target_a target_b].map { |fn| File.join tmpdir, fn } }

    subject do
      described_class.new name: 'touch',
                          sources: [],
                          targets: targets,
                          command_line: "touch #{targets.join ' '}"
    end

    it 'runs if no targets exist' do
      expect { subject.run! }
        .to change { subject.status&.exited? }.from(nil).to(true)
    end

    it 'runs if some targets exist' do
      `touch #{targets[0]}`

      expect { subject.run! }
        .to change { subject.status&.exited? }.from(nil).to(true)
    end

    it 'skips if all targets exist' do
      `touch #{targets.join ' '}`

      expect { subject.run! }
        .to_not change { subject.status&.exited? }.from(nil)
    end
  end

  describe 'execution checking' do
    let(:target) { File.join tmpdir, 'target' }

    subject do
      described_class.new name: 'exit',
                          sources: [],
                          targets: [target],
                          command_line: 'exit 99'
    end

    it 'raises an error' do
      expect { subject.run! }
        .to raise_exception Antex::Command::ExecutionFailed
    end
  end

  describe 'targets checking (post)' do
    let(:targets) { %w[target_a target_b].map { |fn| File.join tmpdir, fn } }

    subject do
      described_class.new name: 'touch',
                          sources: [],
                          targets: targets,
                          command_line: "touch #{targets[0]}"
    end

    it 'raises unless all targets are created' do
      expect { subject.run! }
        .to raise_exception Antex::Command::MissingTargetFiles
    end
  end
end
