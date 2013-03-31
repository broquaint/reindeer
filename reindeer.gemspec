lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "reindeer/version"

Gem::Specification.new do |s|
  s.name    = 'reindeer'
  s.version = Reindeer::VERSION

  s.required_ruby_version = ">= 1.9"
  
  s.summary     = "Moose sugar in Ruby"
  s.description = "Adds featureful attributes, roles and type constraints"

  s.authors  = ["Dan Brook"]
  s.email    = 'dan@broquaint.com'
  s.homepage = 'http://github.com/broquaint/reindeer'

  s.files        = `git ls-files`.split("\n") - %w(.rvmrc .gitignore)
  s.test_files   = `git ls-files spec`.split("\n")

  s.add_development_dependency 'rake',  '~> 0.9.2'
  s.add_development_dependency 'rspec', '~> 2'
end
