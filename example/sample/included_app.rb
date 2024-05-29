# frozen_string_literal: true

require "wamp"

# Class that can be included
class IncludedApp < Wamp::App
  register echo: "foo.bar.echo"

  def echo(invocation)
    Wamp::Type::Result.new(args: invocation.args, kwargs: invocation.kwargs, details: invocation.details)
  end
end
