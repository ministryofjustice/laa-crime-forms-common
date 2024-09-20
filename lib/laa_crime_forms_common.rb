mydir = __dir__

require "i18n"

I18n.load_path += Dir[File.join(mydir, "locales", "**/*.yml")]
