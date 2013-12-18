# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "hyperflow-amqp-executor"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kamil Figiela"]
  s.date = "2013-12-18"
  s.description = "AMQP job executor for Hyperflow workflow engine (http://github.com/dice-cyfronet/hyperflow)"
  s.email = "kamil.figiela@gmail.com"
  s.executables = ["hyperflow-amqp-executor", "hyperflow-amqp-metric-collector"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "Rakefile",
    "VERSION",
    "bin/hyperflow-amqp-executor",
    "bin/hyperflow-amqp-metric-collector",
    "hyperflow-amqp-executor.gemspec",
    "lib/hyperflow-amqp-executor.rb",
    "test/helper.rb",
    "test/test_hyperflow-amqp-executor.rb"
  ]
  s.homepage = "http://github.com/kfigiela/hyperflow-amqp-executor"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "AMQP job executor for Hyperflow workflow engine"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fog>, [">= 0"])
      s.add_runtime_dependency(%q<recursive-open-struct>, [">= 0"])
      s.add_runtime_dependency(%q<amqp>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.7"])
      s.add_development_dependency(%q<pry>, [">= 0"])
    else
      s.add_dependency(%q<fog>, [">= 0"])
      s.add_dependency(%q<recursive-open-struct>, [">= 0"])
      s.add_dependency(%q<amqp>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.7"])
      s.add_dependency(%q<pry>, [">= 0"])
    end
  else
    s.add_dependency(%q<fog>, [">= 0"])
    s.add_dependency(%q<recursive-open-struct>, [">= 0"])
    s.add_dependency(%q<amqp>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.7"])
    s.add_dependency(%q<pry>, [">= 0"])
  end
end

