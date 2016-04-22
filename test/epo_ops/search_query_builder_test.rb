require 'test_helper'

class EpoOps::SearchQueryBuilderTest < Minitest::Test
  def test_range_validation
    builder = EpoOps::SearchQueryBuilder
    assert_equal [1, 100], builder.send(:validate_range, 1, 100)
    assert_equal [1, 25], builder.validate_range(-12, 12)
    assert_equal [1, 11], builder.send(:validate_range, -12, -2)
    assert_equal [1, 100], builder.send(:validate_range, 1, 200)
    assert_equal [1989, 2000], builder.send(:validate_range, 1999, 2010)
    assert_equal [1901, 2000], builder.send(:validate_range, 2020, 2200)
    assert_equal [1, 100], builder.send(:validate_range, -2000, 2000)
    assert_equal [1, 100], builder.send(:validate_range, 100, 1)
    assert_equal [101, 101], builder.send(:validate_range, 101, 101)
  end

  def test_build_query
    query = EpoOps::SearchQueryBuilder.build('A', Date.new(2016, 2, 10), 1, 2)
    assert_equal 'q=pd=20160210 and ic=A&Range=1-2', query
  end

  def test_build_parameters
    query = EpoOps::SearchQueryBuilder.build(nil, Date.new(2016, 2, 10), 1, 100)
    assert_equal 'q=pd=20160210&Range=1-100', query
    query = EpoOps::SearchQueryBuilder.build('A', Date.new(2016, 2, 10), 4, 300)
    assert_equal 'q=pd=20160210 and ic=A&Range=4-103', query
  end
end
