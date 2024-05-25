# frozen_string_literal: true

module Wamp
  # WAMPApp
  class App
    def initialize
      @procedures = {}
    end

    def include_app(app, prefix = "")
      if prefix&.length&.zero?
        procedures.merge!(app.procedures)
      else
        app.procedures.each do |procedure, func|
          procedures.merge!({ "#{prefix}#{procedure}" => func })
        end
      end
    end

    def procedures
      return {} if self.class.procedures && self.class.procedures.empty?
      return @procedures if @procedures.any?

      self.class.procedures.map do |procedure, registration_name|
        @procedures[registration_name.to_s] = method(procedure)
      end
      @procedures
    end

    class << self
      attr_reader :procedures

      def register(procedures = {})
        @procedures ||= {}
        @procedures.merge!(procedures)
      end
    end
  end
end
