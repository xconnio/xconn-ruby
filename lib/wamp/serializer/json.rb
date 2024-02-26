# frozen_string_literal: true

require "json"

module Wamp
  module Serializer
    # Add common API for serializer
    class JSON
      def self.encode(message)
        ::JSON.dump(message)
      end

      def self.decode(message)
        ::JSON.parse(message)
      end
    end
  end
end
