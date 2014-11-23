# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/provisioner/cfengine_version.rb'

Gem::Specification.new do |spec|
  spec.name          = "kitchen-cfengine"
  spec.version       = Kitchen::Provisioner::CFENGINE_VERSION
  spec.authors       = ["Nathan Mische"]
  spec.email         = ["nmische@gmail.com"]
  spec.description   = "Kitchen::Provisioner::CFEngine - A CFEngine Provisioner for Test Kitchen."
  spec.homepage      = "https://github.com/nmische/kitchen-cfengine/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'test-kitchen', '~> 1.0'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"

end
