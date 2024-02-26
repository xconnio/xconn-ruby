# frozen_string_literal: true

require_relative "wamp/version"
require_relative "wamp/connection/base"
require_relative "wamp/serializer"
require_relative "wamp/message"
require_relative "wamp/manager"

module Wamp
  class Error < StandardError; end
  # Your code goes here...
end
