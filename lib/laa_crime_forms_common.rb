require "i18n"
require "json-schema"
require "laa_crime_forms_common/anonymiser"
require "laa_crime_forms_common/assignment"
require "laa_crime_forms_common/autogrant/prior_authority"
require "laa_crime_forms_common/hooks"
require "laa_crime_forms_common/pricing/nsm"
require "laa_crime_forms_common/validator"
require "laa_crime_forms_common/messages/prior_authority"

mydir = __dir__
I18n.load_path += Dir[File.join(mydir, "locales", "**/*.yml")]

module LaaCrimeFormsCommon; end
