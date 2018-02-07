require "./base"

module Amber::Controller
  class Error < Base
    def initialize(@context : HTTP::Server::Context, @ex : Exception)
      super(@context)
      @context.response.content_type = content_type
    end

    def not_found
      response_format(@ex.message)
    end

    def internal_server_error
      response_format("ERROR: #{@ex.inspect_with_backtrace}")
      # IMPORTANT: #inspect_with_backtrace will fail in some situtions which breaks the tests.
      # Even if you call @ex.callstack you'll notice that backtrace is nil.
      # #backtrace? is supposed to be safe but it exceptions anyway.
      # Please don't remove this without verifying that crystal core has been fixed first.
    rescue ex : IndexError
      response_format("ERROR: #{@ex.message}")
    end

    def forbidden
      response_format(@ex.message)
    end

    private def content_type
      if context.request.headers["Accept"]?
        request.headers["Accept"].split(",").first
      else
        "text/html"
      end
    end

    private def response_format(message)
      case content_type
      when "application/json"
        {"error": message}.to_json
      when "text/html"
        "<html><body><pre>#{message}</pre></body></html>"
      else
        message
      end
    end
  end
end
