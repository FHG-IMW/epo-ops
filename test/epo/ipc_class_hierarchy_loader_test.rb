require 'test_helper'
require 'epo/ops/ipc_class_hierarchy_loader'

module Epo
  class IpcClassHierarchyTest < Minitest::Test

    def test_process_file
      VCR.use_cassette('wipo', record: :new_episodes) do

        url = 'http://www.wipo.int/ipc/itos4ipc/ITSupport_and_download_area/20160101/IPC_scheme_title_list/EN_ipc_section_A_title_list_20160101.txt'
        proxy =Epo::Ops::IpcClassHierarchyLoader.send(:proxy)
        file = HTTParty.get(url, http_proxyaddr: proxy[:addr], http_proxyport: proxy[:port]).body
        hierarchy = Epo::Ops::IpcClassHierarchyLoader.send(:process_file, file)
        assert hierarchy
        assert_instance_of Hash, hierarchy
        assert hierarchy['A']
      end
    end
  end
end
