# frozen_string_literal: true

require_relative "abort"

module Wamp
  module Manager
    module Event
      # Abort Message Event
      class Goodbye < Abort
      end
    end
  end
end
