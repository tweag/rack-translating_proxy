# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'rack-translating_proxy'
  spec.version       = '0.1.0'
  spec.authors       = ['Mike Nicholaides']
  spec.email         = ['mike.nicholaides@gmail.com']
  spec.summary       = 'Proxy that translates strings'
  spec.description   = 'Proxy that translates strings'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_dependency 'rack-proxy', '~> 0.5'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop', '0.25'
end
