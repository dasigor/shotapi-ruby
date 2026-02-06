# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'shotapi'
  spec.version       = '1.0.0'
  spec.authors       = ['ShotAPI']
  spec.email         = ['support@shotapi.net']

  spec.summary       = 'Official Ruby SDK for ShotAPI - Screenshot & Rendering API'
  spec.description   = 'Take screenshots, render HTML to images, extract metadata, and compare pages visually with ShotAPI.'
  spec.homepage      = 'https://shotapi.net'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/dasigor/shotapi-ruby'
  spec.metadata['changelog_uri'] = 'https://github.com/dasigor/shotapi-ruby/blob/main/CHANGELOG.md'

  spec.files = Dir['lib/**/*', 'LICENSE', 'README.md']
  spec.require_paths = ['lib']
end
