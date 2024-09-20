source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in laa_crime_forms_common.gemspec.
gemspec

group :development, :test do
  gem "debug"
  gem "pry"
  gem "rubocop-govuk", require: false
  gem "rubocop-performance", ">= 1.17.0", require: false
end

group :test do
  gem "rspec_junit_formatter", require: false
  gem "rspec-rails", ">= 6.1.2"
  gem "simplecov"
  gem "simplecov-rcov"
end
