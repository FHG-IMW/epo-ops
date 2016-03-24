require 'test_helper'

module Epo
  class ErrorTest < Minitest::Test
    # .from_response

    Response = Struct.new(:status, :parsed, :headers)

    def test_return_an_error_that_matches_the_responses_status_code
      response = Response.new(500, {}, {})

      assert_instance_of EpoOps::Error::InternalServerError, EpoOps::Error.from_response(response)
    end

    def test_raise_an_AccessTokenExpired_error_if_special_header_is_set
      token_expired_header = {
        'access-control-allow-headers' => 'Authorization',
        'access-control-allow-methods' => 'POST',
        'access-control-allow-origin' => '*',
        'connection' => 'Close',
        'content-length' => '130',
        'content-type' => 'application/xml',
        'date' => 'Thu, 25 Feb 2016 12:10:08 GMT',
        'server' => 'Apigee Router',
        'www-authenticate' => "Bearer realm=\"null\",error='invalid_token\",error_description='keymanagement.service.access_token_expired: Access Token expired\""
      }

      response = mock('response')
      response.expects(:status).returns(400)
      response.expects(:parsed).returns({})
      response.expects(:headers).times(3).returns(token_expired_header)

      error = EpoOps::Error.from_response(response)

      assert_equal EpoOps::Error::AccessTokenExpired, error.class
    end

    # .parse_error

    def test_return_the_error_message_if_it_is_given
      assert_equal 'An error', EpoOps::Error.send(:parse_error, 'error' => { 'message' => 'An error' })
    end

    # .initialize

    def test_set_message_status_code_and_rate_limit
      response = Response.new(401, { 'error' => { 'message' => 'An error' } }, 'rate_limit' => 'stub')
      error = EpoOps::Error.from_response(response)
      assert_equal 'An error', error.message
      assert_equal 401, error.code
    end

    def test_rate_limit_exceeded
      VCR.insert_cassette('epo_rate_limit_exceeded')
      query = EpoOps::SearchQueryBuilder.build(nil, Date.new(2014, 01, 15), 1, 2)
      begin
        EpoOps::Register.raw_search(query)
      rescue EpoOps::Error::TooManyRequests => error
        rate_limit = error.rate_limit
        assert_equal :hourly_quota, rate_limit.rejection_reason
      end
      VCR.eject_cassette
    end
  end
end
