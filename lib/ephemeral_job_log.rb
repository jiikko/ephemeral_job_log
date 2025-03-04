# frozen_string_literal: true

require_relative "ephemeral_job_log/version"
require_relative "ephemeral_job_log/base"
require_relative "ephemeral_job_log/has_current"

module EphemeralJobLog
  class Error < StandardError; end

  class NoAvailablePositionError < StandardError; end
end
