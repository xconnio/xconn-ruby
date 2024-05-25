# frozen_string_literal: true

require "wamp"

# Class that can be included
class IncludedApp < Wamp::App
  register echo: "foo.bar.echo"

  def echo(invocation)
    Wampproto::Message::Yield.new(invocation.request_id, {}, "INCLUDED", name: "Ismail")
  end
end
