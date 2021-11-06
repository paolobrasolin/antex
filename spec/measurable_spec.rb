# frozen_string_literal: true

require 'spec_helper'

describe Antex::Measurable do
  describe '.new' do
    subject { Antex::Measurable.new }

    it 'initializes with no measures' do
      expect(subject.measures).to be_empty
    end

    it 'initializes with no default unit' do
      expect(subject.default_unit).to be nil
    end
  end

  describe '#measures=' do
    subject { Antex::Measurable.new }

    it 'accepts a hash of measures' do
      expect { subject.measures = { foo: 1, bar: 2 } }.
        to change { subject.measures }.from({}).to(foo: 1, bar: 2)
    end

    it 'resets the default unit' do
      subject.measures = { foo: 1 }
      subject.default_unit = :foo

      expect { subject.measures = { bar: 2 } }.
        to change { subject.default_unit }.from(:foo).to(nil)
    end
  end

  describe '#default_unit=' do
    subject { Antex::Measurable.new }
    before { subject.measures = { foo: 1, bar: 0 } }

    it 'sets the default unit' do
      expect { subject.default_unit = :foo }.
        to change { subject.default_unit }.from(nil).to(:foo)
    end

    it 'raises if unit is zero' do
      expect { subject.default_unit = :bar }.
        to raise_error Antex::Measurable::InvalidUnit
    end

    it 'raises if unit is undefined' do
      expect { subject.default_unit = :baz }.
        to raise_error Antex::Measurable::InvalidUnit
    end
  end

  describe 'dynamic methods' do
    subject { Antex::Measurable.new }
    before { subject.measures = { zero: 0, one: 1, two: 2 } }

    it 'cannot reach undefined measures' do
      expect(subject).to_not respond_to(:foo)
      expect { subject.foo }.to raise_error NoMethodError
    end

    it 'can reach all defined measures' do
      expect(subject).to respond_to(:zero, :one, :two)
    end

    it 'cannot use default unit if not set' do
      expect { subject.one }.to raise_error Antex::Measurable::InvalidUnit
    end

    it 'cannot use undefined measures as units' do
      expect { subject.one :foo }.to raise_error Antex::Measurable::InvalidUnit
    end

    it 'cannot use a metric with value zero as unit' do
      expect { subject.one :zero }.to raise_error Antex::Measurable::InvalidUnit
    end

    it 'return float results' do
      expect(subject.one(:two)).to eq(0.5)
      subject.default_unit = :two
      expect(subject.one).to eq(0.5)
    end
  end
end
