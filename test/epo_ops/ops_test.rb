require 'test_helper'

module EpoOps
  class OpsTest < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::EpoOps::VERSION
    end
  end
end
