# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :development, :ci do
  gem 'rspec', '~> 3.13'
  gem 'simplecov', '~> 1.1'
end

group :development do
  gem 'guard', '~> 2.20'
  gem 'guard-rspec', '~> 4.7'
  if RUBY_VERSION >= '2.7'
    gem 'rubocop', '~> 1.82'
  end
  gem 'yard', '~> 0.9'
end
