require 'epo/ops/rate_limit'

module Epo
  module Ops
    class Error < StandardError
      # @return [Integer]
      attr_reader :code, :rate_limit

      # Raised when EPO returns a 4xx HTTP status code
      ClientError = Class.new(self)
      # Raised when EPO returns the HTTP status code 400
      BadRequest = Class.new(ClientError)
      # Raised when EPO returns the HTTP status code 401
      Unauthorized = Class.new(ClientError)
      # Raised when EPO returns the HTTP status code 403
      Forbidden = Class.new(ClientError)
      # Raised when EPO returns the HTTP status code 404
      NotFound = Class.new(ClientError)
      # Raised when EPO returns the HTTP status code 406
      NotAcceptable = Class.new(ClientError)
      # Raised when EPO returns the HTTP status code 422
      UnprocessableEntity = Class.new(ClientError)
      # Raised when EPO returns the HTTP status code 429
      TooManyRequests = Class.new(ClientError)
      # Raised when EPO returns a 5xx HTTP status code
      ServerError = Class.new(self)
      # Raised when EPO returns the HTTP status code 500
      InternalServerError = Class.new(ServerError)
      # Raised when EPO returns the HTTP status code 502
      BadGateway = Class.new(ServerError)
      # Raised when EPO returns the HTTP status code 503
      ServiceUnavailable = Class.new(ServerError)
      # Raised when EPO returns the HTTP status code 504
      GatewayTimeout = Class.new(ServerError)

      ERRORS = {
        400 => Epo::Ops::Error::BadRequest,
        401 => Epo::Ops::Error::Unauthorized,
        403 => Epo::Ops::Error::Forbidden,
        404 => Epo::Ops::Error::NotFound,
        406 => Epo::Ops::Error::NotAcceptable,
        422 => Epo::Ops::Error::UnprocessableEntity,
        429 => Epo::Ops::Error::TooManyRequests,
        500 => Epo::Ops::Error::InternalServerError,
        502 => Epo::Ops::Error::BadGateway,
        503 => Epo::Ops::Error::ServiceUnavailable,
        504 => Epo::Ops::Error::GatewayTimeout
      }.freeze
      FORBIDDEN_MESSAGES = {
        'This request has been rejected due to the violation of Fair Use policy' => Epo::Ops::Error::TooManyRequests
      }.freeze

      class << self
        # Parses an error from the given response
        # @return [Error]
        def from_response(response)
          code = response.status
          message = parse_error(response.parsed)

          if code == 403 && FORBIDDEN_MESSAGES[message]
            FORBIDDEN_MESSAGES[message].new(message, response.headers, code)
          else
            ERRORS[code].new(message, response.headers, code)
          end
        end

        private

        def parse_error(body)
          if body.nil? || body.empty?
            nil
          elsif body['error'] && body['error']['message']
            body['error']['message']
          end
        end
      end

      def initialize(message = '', rate_limit = {}, code = nil)
        super(message)
        @code = code
        @rate_limit = RateLimit.new(rate_limit)
      end
    end
  end
end
