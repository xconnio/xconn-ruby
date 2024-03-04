# frozen_string_literal: true

require_relative "base"

module Wamp
  module Manager
    module Event
      # Publish Message Event
      class Publish < Base
        def add_event_listener(&block)
          session.transmit(payload)
          return unless block_given?

          session.on(listen_event_name) do |publication|
            session.off(listen_event_name)
            block.call(publication, nil)
          end
        end
      end
    end
  end
end
