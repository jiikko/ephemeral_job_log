# frozen_string_literal: true

require 'logger'
require 'active_support/all'

require_relative 'ephemeral_job_log/version'
require_relative 'ephemeral_job_log/base'

module EphemeralJobLog
  class Error < StandardError; end

  class NoAvailablePositionError < StandardError; end
end
