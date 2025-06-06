require "active_support"
require "active_support/testing/time_helpers"
require "active_support/core_ext/date_time"
require "active_support/core_ext/numeric"

ActiveSupport.to_time_preserves_timezone = :zone

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
end
