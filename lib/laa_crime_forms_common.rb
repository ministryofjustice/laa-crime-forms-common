require "i18n"
require "json-schema"
require "active_model"
require "laa_crime_forms_common/anonymiser"
require "laa_crime_forms_common/assignment"
require "laa_crime_forms_common/autogrant/prior_authority"
require "laa_crime_forms_common/hooks"
require "laa_crime_forms_common/messages/prior_authority"
require "laa_crime_forms_common/pricing/nsm"
require "laa_crime_forms_common/s3_files"
require "laa_crime_forms_common/validator"
require "laa_crime_forms_common/working_day_service"
require "laa_crime_forms_common/number_to"
require "laa_crime_forms_common/court"
require "laa_crime_forms_common/main_offence"
require "laa_crime_forms_common/outcome_code"
require "laa_crime_forms_common/matter_type"

Dir["#{File.join(__dir__, './laa_crime_forms_common/attributes/type')}/*.rb"].each { |f| require f }
Dir["#{File.join(__dir__, './laa_crime_forms_common/validators')}/*.rb"].each { |f| require f }

mydir = __dir__
I18n.load_path += Dir[File.join(mydir, "locales", "**/*.yml")]
I18n.available_locales = [:en]
I18n.default_locale = :en

module LaaCrimeFormsCommon; end
