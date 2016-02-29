module Epo
  module Ops
    # Used to represent persons or companies (or both) in patents. Used for
    # both, agents and applicants. Most of the time, when `name` is a person
    # name, `address1` is a company name. Be aware that the addresses are in
    # their respective local format.
    #
    # Current patents usually at least use the fields address1-3, so they should
    # nearly always have values. Nevertheless, older ones often only use 1-2.
    # Note also that EPOs schema documents fields like `street` or `city`, but
    # by now they have not been used yet.
    #
    # @attr [String] name the name of an entity (one or more persons or
    #   companies)
    # @attr [String] address1 first address line. May also be a company name
    # @attr [String] address2 second address line
    # @attr [String] address3 third address line, may be empty
    # @attr [String] address4 fourth address line, may be empty
    # @attr [String] address5 fifth address line, may be empty
    # @attr [String] country_code two letter country code of the address
    # @attr [Date] occurred_on the date an address occurred on, usually matching
    #   the entries change_gazette_num
    # @attr [String] cdsid some kind of id the EPO provides, not sure yet if
    #   usable as reference.
    class Address
      attr_reader :name, :address1,
                  :address2,
                  :address3,
                  :address4,
                  :address5,
                  :country_code,
                  :occurred_on,
                  :cdsid
      def initialize(name, address1, address2, address3, address4,
                     address5, country_code, occurred_on,
                     cdsid)
        @address1 = address1
        @address2 = address2
        @address3 = address3 || ''
        @address4 = address4 || ''
        @address5 = address5 || ''
        @name = name
        @country_code = country_code || ''
        @occurred_on = occurred_on || ''
        @cdsid = cdsid || ''
      end

      # Compare addresses by the name and address fields.
      # @return [Boolean]
      def equal_name_and_address?(other)
        name == other.name &&
          address1 == other.address1 &&
          address2 == other.address2 &&
          address3 == other.address3 &&
          address4 == other.address4 &&
          address5 == other.address5
      end
    end
  end
end
