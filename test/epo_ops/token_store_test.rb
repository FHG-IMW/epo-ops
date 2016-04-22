require 'test_helper'

module EpoOps
  class TokeStoreTest < Minitest::Test
    def test_token_generates_a_new_one_when_there_is_none
      token = mock
      token_store = EpoOps::TokenStore.new

      token_store.expects(:generate_token).returns(token)

      assert_equal token, token_store.token
    end

    def test_existing_token_is_used_if_it_has_not_expired
      token = mock
      token.stubs(:expired?).returns(false)

      token_store = EpoOps::TokenStore.new
      token_store.instance_variable_set('@token', token)

      assert_equal token, token_store.token
    end

    def test_generate_new_token_if_existing_has_expired
      token = mock
      token.stubs(:expired?).returns(true)

      token_store = EpoOps::TokenStore.new
      token_store.instance_variable_set('@token', token)

      token_store.expects(:generate_token).returns(token)

      token_store.token
    end

    def test_rest_resets_the_access_token
      token = mock

      token_store = EpoOps::TokenStore.new
      token_store.instance_variable_set('@token', token)

      token_store.reset

      assert_nil token_store.instance_variable_get('@token')
    end
  end
end
