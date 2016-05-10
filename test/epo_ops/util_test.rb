require 'test_helper'

module EpoOps
  class UtilTest < Minitest::Test

    # dig
    def test_traverse_the_path_and_return_a_single_result
      data = {foo: {bar: {baz: 'foobarbaz'}}}
      assert_equal 'foobarbaz', EpoOps::Util.dig(data,:foo,:bar,:baz)
    end

    def test_return_nil_if_path_does_not_exist
      data = {foo: {bar: [{baz: 'foobarbaz'}]}}
      assert_nil EpoOps::Util.dig(data,:foo,:bar,:baz)
    end

    #flat_dig
    def test_traverse_a_nested_hash
      data = {foo: {bar: {baz: 'foobarbaz'}}}
      assert_equal ['foobarbaz'], EpoOps::Util.flat_dig(data,:foo,:bar,:baz)
    end

    def test_traverse_mixed_nested_hashs_and_arrays
      data = {foo: {bar: [ {baz: '1'}, {baz: '2'} ] }}
      assert_equal ['1','2'], EpoOps::Util.flat_dig(data,:foo,:bar,:baz)
    end

    def test_ignore_empty_paths_in_mixed_nested_hash_and_array
      data = {
          foo: [
              {bar: {baz: 1}},
              {bar: 2},
              3
          ]
      }

      assert [1], EpoOps::Util.flat_dig(data,:foo,:bar,:baz)
    end

  end
end
