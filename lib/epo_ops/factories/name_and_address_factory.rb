module EpoOps
  module Factories
    # Parses the addressbook data from EPO Ops into an 'NameAndAddress' object
    class NameAndAddressFactory
      class << self

        # @param raw_data [Hash] raw addressbook data as retrieved included in Epo Ops biblio data
        # @return [EpoOps::NameAndAddress] NameAndAddress filled with parsed data
        def build(raw_data)
          factory = new(raw_data)

          EpoOps::NameAndAddress.new(
              factory.name,
              factory.address_1,
              factory.address_2,
              factory.address_3,
              factory.address_4,
              factory.address_5,
              factory.country_code,
              factory.cdsid
          )
        end
      end

      attr_reader :raw_data,
                  :name,
                  :address_1,
                  :address_2,
                  :address_3,
                  :address_4,
                  :address_5,
                  :country_code,
                  :cdsid


      def initialize(raw_data)
        @raw_data = raw_data

        @name         = raw_data['name']

        if raw_data['address'].is_a? Hash
          @address_1    = raw_data['address']['address_1']
          @address_2    = raw_data['address']['address_2']
          @address_3    = raw_data['address']['address_3']
          @address_4    = raw_data['address']['address_4']
          @address_5    = raw_data['address']['address_5']
          @country_code = raw_data['address']['country']
        end

        @cdsid        = raw_data['cdsid']
      end
    end
  end
end
