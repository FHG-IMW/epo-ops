require 'epo/ops'
require 'epo/ops/client'

module Epo
  module Ops
    class Register
      def self.search(_query)
        Epo::Ops::Client.request(:get, '/3.1/rest-services/register/search?q=pd=20160203')
      end
    end
  end
end
