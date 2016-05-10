require 'test_helper'
require 'yaml'

module Epo
  module Ops
    class RegisterSearchResultFactoryTest < Minitest::Test
      def setup
        @data = YAML.load File.read("test/test_data/search_data.yaml")
        @factory = EpoOps::Factories::RegisterSearchResultFactory.new(@data)
      end

      def test_patent_count
        assert_equal 8965, @factory.count
      end

      def test_patent_extraction
        assert_equal 2, @factory.patents.count
        assert_equal 'EP15474002', @factory.patents.first.application_nr
      end

      def test_build
        res = EpoOps::Factories::RegisterSearchResultFactory.build @data
        assert_equal 8965, res.count
        assert_equal 2, res.patents.count
      end
    end
  end
end
