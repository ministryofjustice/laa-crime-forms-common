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
  gem "rspec", ">= 3.13.0"
  gem "rspec_junit_formatter", require: false
  gem "simplecov"
  gem "simplecov-rcov"
  gem "super_diff", "~> 0.17.0"
  gem "webmock"
end
