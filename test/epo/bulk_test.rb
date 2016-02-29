require 'test_helper'
require 'epo/ops/register'

module Epo
  class BulkTest < Minitest::Test
    # TODO: test with mocks, this way takes too long and space
    # def test_all_register_references
    #   date = Date.new(2016,2,3)
    #   count = Epo::Ops::Register::Bulk.published_patents_count(date)
    #   refs = Epo::Ops::Register::Bulk
    #         .all_register_references(date)
    #  assert_equal count, refs.count
    # end
  end
end
