require 'test_helper'
require 'yaml'

module EpoOps
  class RegisterSearchResultTest < Minitest::Test
    def setup
      @data = YAML.load File.read("test/test_data/search_data.yaml")
      @result = EpoOps::Factories::RegisterSearchResultFactory.build(@data)
    end

    def test_patent_count
      assert_equal 8965, @result.count
    end

    def test_patent_extraction
      assert_equal 2, @result.patents.count
      assert_equal 'EP15474002', @result.patents.first.application_nr
    end

    def test_enumerable_integration
      assert_equal ["EP15474002", "EP15461538"], @result.map {|res| res.application_nr}
    end

    def test_count_for_null_result
      result = EpoOps::RegisterSearchResult::NullResult.new
      assert_equal 0, result.count
    end

    def test_return_empty_array_for_null_result_patents
      result = EpoOps::RegisterSearchResult::NullResult.new
      assert_equal [], result.patents
    end
  end
end
