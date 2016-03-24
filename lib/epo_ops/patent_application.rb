module Epo
  class PatentApplication

    # @return [String]
    attr_reader :application_nr
    # @return [Hash]
    attr_reader :raw_data

    def initialize(data={})

    end

    def title

    end


    def parse_latest_update
      gazette_nums = Extraction::Epo::Util.parse_hash_flat(raw, 'change_gazette_num')
      nums = gazette_nums.map { |num| Extraction::Epo::Util.parse_change_gazette_num(num) }.keep_if { |match| !match.nil? }
      nums.max
    end

    def url
      @url ||= "https://ops.epo.org/3.1/rest-services/register/application/epodoc/#{application_nr}"
    end
  end
end