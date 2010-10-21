# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{capybara-faraday}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jonathan Tron", "Joseph HALTER"]
  s.date = %q{2010-10-21}
  s.summary = %q{Faraday driver for Capybara}
  s.description = %q{Faraday driver for Capybara, allowing testing of REST APIs}

  s.email = %q{team@openhood.com}
  s.files = Dir.glob("{lib,spec}/**/*") + %w(README.md)
  s.homepage = %q{http://github.com/openhood/capybara-faraday}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  
  s.add_runtime_dependency(%q<capybara>, ["~> 0.4.0.rc"])
  s.add_runtime_dependency(%q<faraday>, ["~> 0.5.1"])
end
