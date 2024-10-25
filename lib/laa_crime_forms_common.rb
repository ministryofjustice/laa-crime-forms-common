require "i18n"
require "json-schema"
require "laa_crime_forms_common/validator"
require "laa_crime_forms_common/pricing/nsm"

mydir = __dir__
I18n.load_path += Dir[File.join(mydir, "locales", "**/*.yml")]

module LaaCrimeFormsCommon; end
