# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'text_based_nested_set/version'

Gem::Specification.new do |spec|
  spec.name          = "text_based_nested_set"
  spec.version       = TextBasedNestedSet::VERSION
  spec.authors       = ["beyondalbert"]
  spec.email         = ["beyondalbert@gmail.com"]
  spec.summary       = %q{Text based nested set.}
  spec.description   = %q{Text based nested set.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "factory_girl", "~> 4.0"
  spec.add_development_dependency "mysql2", "~> 0.3.17"
  spec.add_development_dependency 'combustion', '>= 0.5.2'
  spec.add_development_dependency 'database_cleaner', '~> 1.4.0'
  spec.add_dependency "activerecord", "~> 4.0"
end
