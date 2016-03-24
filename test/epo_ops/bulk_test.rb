require 'test_helper'

module Epo
  class BulkTest < Minitest::Test
    # TODO: test with mocks, this way takes too long and space
    # def test_all_register_references
    #   date = Date.new(2016,2,3)
    #   count = EpoOps::Register::Bulk.published_patents_count(date)
    #   refs = EpoOps::Register::Bulk
    #         .all_register_references(date)
    #  assert_equal count, refs.count
    # end
  end
end
