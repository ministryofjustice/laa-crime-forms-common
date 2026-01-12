require_relative "lib/laa_crime_forms_common/version"

Gem::Specification.new do |spec|
  spec.name        = "laa_crime_forms_common"
  spec.version     = LaaCrimeFormsCommon::VERSION
  spec.authors     = ["LAA NSCC"]
  spec.email       = ["nscc@justice.gov.uk"]
  spec.summary     = "Shared code for LAA crime forms applications"
  spec.description = "Data and functionality shared across Submit a crime form and Assess a crime form"
  spec.required_ruby_version = ">= 3.3"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = ""
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{config,lib}/**/*", "LICENSE", "README.md"]
  end

  spec.add_dependency("activesupport")
  spec.add_dependency("httparty", ">= 0.24.0", "< 1")
  spec.add_dependency("i18n", ">= 1.8.11", "< 2")
  spec.add_dependency("json-schema", ">= 5.0.0", "< 7")
  spec.add_dependency("uuid", "~> 2.3")
  spec.metadata["rubygems_mfa_required"] = "true"
end
