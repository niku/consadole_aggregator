# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{consadole_aggregator}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["niku"]
  s.date = %q{2011-05-06}
  s.default_executable = %q{consadole_aggregator}
  s.description = %q{ It aggregates infomation of 'Consadole Sapporo' }
  s.email = %q{niku@niku.name}
  s.executables = ["consadole_aggregator"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "account.yaml",
    "bin/consadole_aggregator",
    "consadole_aggregator.gemspec",
    "db/.gitignore",
    "lib/consadole_aggregator.rb",
    "lib/consadole_aggregator/helper.rb",
    "lib/consadole_aggregator/live.rb",
    "lib/consadole_aggregator/live/timeline.rb",
    "lib/consadole_aggregator/news.rb",
    "log/.gitignore",
    "spec/consadole_aggregator/helper_spec.rb",
    "spec/consadole_aggregator/live/timeline_spec.rb",
    "spec/consadole_aggregator/live_spec.rb",
    "spec/consadole_aggregator/news_spec.rb",
    "spec/ext/asahi.txt",
    "spec/ext/consaburn.txt",
    "spec/ext/consaclub.txt",
    "spec/ext/consadolenews.txt",
    "spec/ext/consadolephotos.txt",
    "spec/ext/consadolesponsornews.txt",
    "spec/ext/forzaconsadole.txt",
    "spec/ext/hochiyomiuri.txt",
    "spec/ext/jsgoalnews.txt",
    "spec/ext/jsgoalphotos.txt",
    "spec/ext/live/s674.html",
    "spec/ext/live/s674.html.1",
    "spec/ext/live/s674.html.10",
    "spec/ext/live/s674.html.100",
    "spec/ext/live/s674.html.101",
    "spec/ext/live/s674.html.102",
    "spec/ext/live/s674.html.103",
    "spec/ext/live/s674.html.104",
    "spec/ext/live/s674.html.105",
    "spec/ext/live/s674.html.106",
    "spec/ext/live/s674.html.107",
    "spec/ext/live/s674.html.108",
    "spec/ext/live/s674.html.109",
    "spec/ext/live/s674.html.11",
    "spec/ext/live/s674.html.110",
    "spec/ext/live/s674.html.111",
    "spec/ext/live/s674.html.112",
    "spec/ext/live/s674.html.113",
    "spec/ext/live/s674.html.114",
    "spec/ext/live/s674.html.115",
    "spec/ext/live/s674.html.116",
    "spec/ext/live/s674.html.117",
    "spec/ext/live/s674.html.118",
    "spec/ext/live/s674.html.119",
    "spec/ext/live/s674.html.12",
    "spec/ext/live/s674.html.120",
    "spec/ext/live/s674.html.13",
    "spec/ext/live/s674.html.14",
    "spec/ext/live/s674.html.15",
    "spec/ext/live/s674.html.16",
    "spec/ext/live/s674.html.17",
    "spec/ext/live/s674.html.18",
    "spec/ext/live/s674.html.19",
    "spec/ext/live/s674.html.2",
    "spec/ext/live/s674.html.20",
    "spec/ext/live/s674.html.21",
    "spec/ext/live/s674.html.22",
    "spec/ext/live/s674.html.23",
    "spec/ext/live/s674.html.24",
    "spec/ext/live/s674.html.25",
    "spec/ext/live/s674.html.26",
    "spec/ext/live/s674.html.27",
    "spec/ext/live/s674.html.28",
    "spec/ext/live/s674.html.29",
    "spec/ext/live/s674.html.3",
    "spec/ext/live/s674.html.30",
    "spec/ext/live/s674.html.31",
    "spec/ext/live/s674.html.32",
    "spec/ext/live/s674.html.33",
    "spec/ext/live/s674.html.34",
    "spec/ext/live/s674.html.35",
    "spec/ext/live/s674.html.36",
    "spec/ext/live/s674.html.37",
    "spec/ext/live/s674.html.38",
    "spec/ext/live/s674.html.39",
    "spec/ext/live/s674.html.4",
    "spec/ext/live/s674.html.40",
    "spec/ext/live/s674.html.41",
    "spec/ext/live/s674.html.42",
    "spec/ext/live/s674.html.43",
    "spec/ext/live/s674.html.44",
    "spec/ext/live/s674.html.45",
    "spec/ext/live/s674.html.46",
    "spec/ext/live/s674.html.47",
    "spec/ext/live/s674.html.48",
    "spec/ext/live/s674.html.49",
    "spec/ext/live/s674.html.5",
    "spec/ext/live/s674.html.50",
    "spec/ext/live/s674.html.51",
    "spec/ext/live/s674.html.52",
    "spec/ext/live/s674.html.53",
    "spec/ext/live/s674.html.54",
    "spec/ext/live/s674.html.55",
    "spec/ext/live/s674.html.56",
    "spec/ext/live/s674.html.57",
    "spec/ext/live/s674.html.58",
    "spec/ext/live/s674.html.59",
    "spec/ext/live/s674.html.6",
    "spec/ext/live/s674.html.60",
    "spec/ext/live/s674.html.61",
    "spec/ext/live/s674.html.62",
    "spec/ext/live/s674.html.63",
    "spec/ext/live/s674.html.64",
    "spec/ext/live/s674.html.65",
    "spec/ext/live/s674.html.66",
    "spec/ext/live/s674.html.67",
    "spec/ext/live/s674.html.68",
    "spec/ext/live/s674.html.69",
    "spec/ext/live/s674.html.7",
    "spec/ext/live/s674.html.70",
    "spec/ext/live/s674.html.71",
    "spec/ext/live/s674.html.72",
    "spec/ext/live/s674.html.73",
    "spec/ext/live/s674.html.74",
    "spec/ext/live/s674.html.75",
    "spec/ext/live/s674.html.76",
    "spec/ext/live/s674.html.77",
    "spec/ext/live/s674.html.78",
    "spec/ext/live/s674.html.79",
    "spec/ext/live/s674.html.8",
    "spec/ext/live/s674.html.80",
    "spec/ext/live/s674.html.81",
    "spec/ext/live/s674.html.82",
    "spec/ext/live/s674.html.83",
    "spec/ext/live/s674.html.84",
    "spec/ext/live/s674.html.85",
    "spec/ext/live/s674.html.86",
    "spec/ext/live/s674.html.87",
    "spec/ext/live/s674.html.88",
    "spec/ext/live/s674.html.89",
    "spec/ext/live/s674.html.9",
    "spec/ext/live/s674.html.90",
    "spec/ext/live/s674.html.91",
    "spec/ext/live/s674.html.92",
    "spec/ext/live/s674.html.93",
    "spec/ext/live/s674.html.94",
    "spec/ext/live/s674.html.95",
    "spec/ext/live/s674.html.96",
    "spec/ext/live/s674.html.97",
    "spec/ext/live/s674.html.98",
    "spec/ext/live/s674.html.99",
    "spec/ext/nikkansports.txt",
    "spec/spec.opts",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/niku/consadole_aggregator}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.2}
  s.summary = %q{It aggregates infomation of 'Consadole Sapporo'}
  s.test_files = [
    "spec/consadole_aggregator/helper_spec.rb",
    "spec/consadole_aggregator/live/timeline_spec.rb",
    "spec/consadole_aggregator/live_spec.rb",
    "spec/consadole_aggregator/news_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_runtime_dependency(%q<oauth>, [">= 0"])
      s.add_runtime_dependency(%q<rubytter>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<oauth>, [">= 0"])
      s.add_dependency(%q<rubytter>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<oauth>, [">= 0"])
    s.add_dependency(%q<rubytter>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
  end
end

