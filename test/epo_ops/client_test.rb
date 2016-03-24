require 'test_helper'

class Epo::ClientTest < Minitest::Test
  # .request

  def test_set_the_accept_header_to_json_and_pass_the_request_to_the_token
    request = mock
    request.expects(:status).returns(200)

    token = mock
    token.expects(:request).with(:get, '/foo/bar', {}).returns(request)

    EpoOps.config.token_store.stubs(:token).returns(token)

    assert_equal request, EpoOps::Client.request(:get, '/foo/bar')
  end

  def test_raise_an_error_if_the_status_code_does_not_equal_200
    request = mock
    request.expects(:status).returns(300)

    token = mock
    token.expects(:request).with(:get, '/foo/bar', {}).returns(request)

    EpoOps.config.token_store.stubs(:token).returns(token)

    EpoOps::Error.expects(:from_response).with(request).returns(EpoOps::Error.new)

    assert_raises EpoOps::Error do
      EpoOps::Client.request(:get, '/foo/bar')
    end
  end

  def test_retry_request_when_access_token_has_expired
    error_response = mock('error response')
    error_response.stubs(:status).returns(400)
    error_response.stubs(:name).returns('error')

    success_response = mock('error response')
    success_response.stubs(:status).returns(200)

    token = mock
    token.stubs(:request).with(:get, '/foo/bar', {}).returns(error_response, success_response)

    EpoOps.config.token_store.stubs(:token).returns(token)

    EpoOps.config.token_store.expects(:reset)

    EpoOps::Error.stubs(:from_response).with(error_response).returns(EpoOps::Error::AccessTokenExpired.new)

    EpoOps::Client.request(:get, '/foo/bar')
  end
end
