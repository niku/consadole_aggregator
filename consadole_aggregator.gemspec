# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "consadole_aggregator/version"

Gem::Specification.new do |s|
  s.name        = "consadole_aggregator"
  s.version     = ConsadoleAggregator::VERSION
  s.authors     = ["niku"]
  s.email       = ["niku@niku.name"]
  s.homepage    = "https://github.com/niku/consadole_aggregator"
  s.summary     = %q{aggregates infomation of 'Consadole Sapporo'}
  #s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "consadole_aggregator"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "ruby_gntp"
  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "eventmachine"
  s.add_runtime_dependency "twitter"
  s.add_runtime_dependency "httpclient"
end
