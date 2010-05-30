# -*- encoding: utf-8 -*-
require 'bundler'

Gem::Specification.new do |s|
  s.name = 'rack-rescue'
  s.version = '0.1.1'
  s.homepage = %q{http://github.com/hassox/rack-rescue}
  s.authors = ["Daniel Neighman"]
  s.autorequire = %q{rack/rescue}
  s.date = Date.today
  s.description = %q{Rescue Handler for Rack}
  s.summary =%q{Rescue Handler for Rack}
  s.email = %q{has.sox@gmail.com}

  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.files = Dir['**/*']

  s.add_bundler_dependencies

end


