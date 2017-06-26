require 'test_helper'

module EpoOps
  module Factories
    class NameAndAddressFactoryTest < Minitest::Test
      def test_building_a_name_and_address
        data = {
          'name' => 'Akzo Nobel IP Department',
          'address' => {
            'address_1' => 'Velperweg 76',
            'address_2' => '6824 BM Arnhem',
            'address_3' => 'address field 3',
            'address_4' => 'address field 4',
            'address_5' => 'address field 5',
            'country' => 'NL',
          },
          'cdsid' => 010060244
        }

        NameAndAddress.expects(:new).with(
          'Akzo Nobel IP Department',
          'Velperweg 76',
          '6824 BM Arnhem',
          'address field 3',
          'address field 4',
          'address field 5',
          'NL',
          010060244
        ).once

        EpoOps::Factories::NameAndAddressFactory.build(data)
      end

      def test_namd_and_address_is_filled_with_address_data_if_not_all_fields_are_set
        data = {
            "name" => "Akzo Nobel Chemicals International B.V.",
            "address" => {
              'address_2' => '3811 MH  Amersfoort',
              'address_1' => 'Stationsstraat 77',
              'country' => 'NL'
            }
        }

        factory = EpoOps::Factories::NameAndAddressFactory.new(data)

        assert_equal 'Akzo Nobel Chemicals International B.V.', factory.name
        assert_equal 'Stationsstraat 77', factory.address_1
        assert_equal '3811 MH  Amersfoort', factory.address_2
        assert_nil factory.address_3
        assert_nil factory.address_4
        assert_nil factory.address_5
      end

      def test_all_5_address_fields_should_be_readable
        data = {
          'name' => 'Akzo Nobel IP Department',
          'address' => {
            'address_1' => 'Velperweg 76',
            'address_2' => '6824 BM Arnhem',
            'address_3' => 'address field 3',
            'address_4' => 'address field 4',
            'address_5' => 'address field 5',
          },
          'country' => 'NL',
          'cdsid' => 010060244
        }

        factory = EpoOps::Factories::NameAndAddressFactory.new(data)

        assert_equal 'Velperweg 76', factory.address_1
        assert_equal '6824 BM Arnhem', factory.address_2
        assert_equal 'address field 3', factory.address_3
        assert_equal 'address field 4', factory.address_4
        assert_equal 'address field 5', factory.address_5
        assert_equal 010060244, factory.cdsid
      end
    end
  end
end
