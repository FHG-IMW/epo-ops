require 'test_helper'

module Epo
  class RegisterQueriesTest < Minitest::Test
    # new function splitting all queries
    def test_all_queries
      VCR.use_cassette('all_queries', allow_playback_repeats: true) do
        EpoOps::IpcClassUtil.stub :main_classes, ['A'] do
          date = Date.new(2016, 1, 20)
          qrys = EpoOps::Register.all_queries(nil, date)
        end
      end
    end
  end
end