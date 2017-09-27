lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_hooks/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_hooks'
  s.version     = SpreeHooks.version
  s.summary     = 'Two engines, one to handle events, under the Observer module and another to perform notifications, under the Hooks module'
  s.description = s.summary
  s.required_ruby_version = '>= 2.2.7'

  s.author       = 'Cenit Team'
  s.email        = 'support@cenit.io'
  s.homepage     = 'https://github.com/cenit-io/spree_hooks'
  s.license      = 'BSD-3'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = false

  s.add_runtime_dependency 'spree_backend', '>= 3.1.0', '< 4.0'
  s.add_runtime_dependency 'spree_extension'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'capybara-screenshot'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'rubocop'
end
