require 'test_helper'

module Epo
  class OpsTest < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::EpoOps::VERSION
    end
  end
end
