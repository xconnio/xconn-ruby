# frozen_string_literal: true

require "wamp"
require "date"
require_relative "included_app"

# SystemApp
class Example < Wamp::App
  register what: "io.xconn.echo", current_date: "io.xconn.date.get"

  def initialize
    super
    include_app(IncludedApp.new, "test.")
  end

  def what(invocation)
    Wampproto::Message::Yield.new(invocation.request_id, {}, *invocation.args, **invocation.kwargs)
  end

  def current_date(invocation)
    Wampproto::Message::Yield.new(invocation.request_id, {}, Date.today.iso8601)
  end
end
