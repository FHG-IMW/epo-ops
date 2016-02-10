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
        400 => WebServices::Epo::Error::BadRequest,
        401 => WebServices::Epo::Error::Unauthorized,
        403 => WebServices::Epo::Error::Forbidden,
        404 => WebServices::Epo::Error::NotFound,
        406 => WebServices::Epo::Error::NotAcceptable,
        422 => WebServices::Epo::Error::UnprocessableEntity,
        429 => WebServices::Epo::Error::TooManyRequests,
        500 => WebServices::Epo::Error::InternalServerError,
        502 => WebServices::Epo::Error::BadGateway,
        503 => WebServices::Epo::Error::ServiceUnavailable,
        504 => WebServices::Epo::Error::GatewayTimeout
      }.freeze
      FORBIDDEN_MESSAGES = {
        'This request has been rejected due to the violation of Fair Use policy' => WebServices::Epo::Error::TooManyRequests
      }.freeze

      class << self
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
        @rate_limit = WebServices::Epo::RateLimit.new(rate_limit)
      end
    end
  end
end
