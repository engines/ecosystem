module Server
  class Api

    class Error < StandardError

      def to_s
        message
      end

      class NotAuthenticated < Error

        def message
          "Not authenticated."
        end

        def status
          401
        end

      end

      class Timeout < Error

        def message
          "Session timeout."
        end

        def status
          418 # Use 418 for timeout, because teapots are always on time.
        end

      end

      class SystemUnavailable < Error

        def message
          "System unavailable."
        end

        def status
          503
        end

      end

      class SystemNotFound < Error

        def initialize(request)
          @request = request
        end

        def message
          "Engines System API route not found: #{
            @request.method.upcase
          } '#{
            URI.parse( @request.url ).path
          }'."
        end

        def status
          500
        end

      end


    end

    not_found do
      content_type :text
      status 404
      'Not found.'
    end

    error Error do |e|
      content_type :text
      status e.status
      e.message
    end

    error do |e|
      message = "\033[1;31mFatal error.\033[0m\n#{ e.full_message }\033[1;31m#{ e }\033[0m"
      logger.error message
      content_type 'text/terminal'
      status 500
      message
    end

  end
end
