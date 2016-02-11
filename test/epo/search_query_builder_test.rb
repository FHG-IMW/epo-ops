require 'test_helper'
require 'epo/ops/search_query_builder'

class Epo::SearchQueryBuilderTest < Minitest::Test

  def test_range_validation
    builder = Epo::Ops::SearchQueryBuilder.new
    assert_equal [1, 100], builder.validate_range( 1, 100)
    assert_equal [1, 25], builder.validate_range( -12, 12)
    assert_equal [1, 11], builder.validate_range( -12, -2)
    assert_equal [1, 100], builder.validate_range( 1, 200)
    assert_equal [1989, 2000], builder.validate_range( 1999, 2010)
    assert_equal [1901, 2000], builder.validate_range( 2020, 2200)
    assert_equal [1, 100], builder.validate_range( -2000, 2000)
  end

  def test_build_query
    builder = Epo::Ops::SearchQueryBuilder.new
    query = builder.publication_date(2016, 2, 10).and.ipc_class("A").build(1,2)
    assert_equal "search?q=pd=20160210 and ic=A&Range=1-2", query
  end

  def test_build_parameters
    builder = Epo::Ops::SearchQueryBuilder.new
    query = builder.publication_date(2016, 2, 10).and.ipc_class("A").build
    assert_equal "search?q=pd=20160210 and ic=A&Range=1-100", query
    builder = Epo::Ops::SearchQueryBuilder.new
    query = builder.publication_date(2016, 2, 10).and.ipc_class("A").build(4)
    assert_equal "search?q=pd=20160210 and ic=A&Range=4-103", query
  end

end
