# frozen_string_literal: true

module Wamp
  module Message
    # validation
    class Validate
      class << self
        def int!(name, value)
          return value if value.is_a?(Integer)

          raise ArgumentError, "The #{name} argument should be an integer."
        end

        def string!(name, value)
          return value if value.is_a?(String)

          raise ArgumentError, "The #{name} argument should be a string."
        end

        def hash!(name, value)
          return value.transform_keys(&:to_sym) if value.is_a?(Hash)

          raise ArgumentError, "The #{name} argument should be a dictionary."
        end

        def array!(name, value)
          return value if value.is_a?(Array)

          raise ArgumentError, "The #{name} argument should be a list."
        end

        def length!(array, expected_length)
          return array if array.length == expected_length

          raise ArgumentError, "The response message length should be #{expected_length} but got #{array.length} "
        end

        def greater_than_equal!(array, expected_length)
          return array if array.length >= expected_length

          raise ArgumentError, "The response message length is #{array.length} but it should be #{expected_length} "
        end

        def options!(options, valid_keys)
          options.each_key do |key|
            raise ArgumentError, "Unrecognized option: #{key.inspect}" unless valid_keys.include?(key)
          end

          options
        end
      end
    end
  end
end
