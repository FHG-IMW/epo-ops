require 'test_helper'
require 'epo/ops/address'
class Epo::Ops::AddressTest < Minitest::Test
  def test_equality
    addr1 = Epo::Ops::Address.new('name', 'a1', 'a2', '', '', '', '', Date.new(2015, 02, 02), '')
    same_as_1 = Epo::Ops::Address.new('name', 'a1', 'a2', '', '', '', '', Date.new(2016, 12, 25), '')
    different = Epo::Ops::Address.new('name', 'a1', 'a2', 'diff', '', '', '', Date.new(2015, 02, 02), '')

    assert addr1.equal_name_and_address?(same_as_1)
    refute addr1.equal_name_and_address?(different)
  end
end
