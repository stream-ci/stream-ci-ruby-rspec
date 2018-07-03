lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "stream_ci_ruby_rspec/version"

Gem::Specification.new do |spec|
  spec.name          = "stream-ci-ruby-rspec"
  spec.version       = StreamCiRubyRspec::VERSION
  spec.authors       = ["James Conant"]
  spec.email         = ["james@conant.io"]

  spec.summary       = "StreamCI rspec runner"
  spec.description   = "StreamCI rspec runner"
  spec.homepage      = "https://www.streamci.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.16', '>= 1.16.2'
  spec.add_development_dependency 'rake', '~> 12.3', '>= 12.3.1'
  spec.add_development_dependency 'rspec', '~> 3.7'
end
