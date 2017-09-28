# frozen_string_literal: true

# Ignore Emacs backup files.
ignore(%r{\/?\.\#})

guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/(.+)_spec.rb$})
  watch(%r{^lib/antex/(.+).rb$}) do |match|
    "spec/#{match[1]}_spec.rb"
  end
end
