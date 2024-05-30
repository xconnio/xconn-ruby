# frozen_string_literal: true

module Wamp
  module Type
    # Publication Type
    class Publication
      attr_reader :publication_id

      def initialize(publication_id: nil)
        @publication_id = publication_id
      end
    end
  end
end
