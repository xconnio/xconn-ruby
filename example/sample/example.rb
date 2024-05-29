# frozen_string_literal: true

require "wamp"
require "date"
require_relative "included_app"

# SystemApp
class Example < Wamp::App
  register echo: "io.xconn.echo", current_date: "io.xconn.date.get"

  def initialize
    super
    include_app(IncludedApp.new, "test.")
  end

  def echo(invocation)
    Wamp::Type::Result.new(args: invocation.args, kwargs: invocation.kwargs, details: invocation.details)
  end

  def current_date(_invocation)
    Wamp::Type::Result.new(args: Date.today.iso8601)
  end
end
