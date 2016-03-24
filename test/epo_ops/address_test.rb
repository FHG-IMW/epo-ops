require 'test_helper'

class EpoOps::AddressTest < Minitest::Test
  def test_equality
    addr1 = EpoOps::NameAndAddress.new('name', 'a1', 'a2', '', '', '', '', Date.new(2015, 02, 02), '')
    same_as_1 = EpoOps::NameAndAddress.new('name', 'a1', 'a2', '', '', '', '', Date.new(2016, 12, 25), '')
    different = EpoOps::NameAndAddress.new('name', 'a1', 'a2', 'diff', '', '', '', Date.new(2015, 02, 02), '')

    assert addr1.equal_name_and_address?(same_as_1)
    refute addr1.equal_name_and_address?(different)
  end
end
