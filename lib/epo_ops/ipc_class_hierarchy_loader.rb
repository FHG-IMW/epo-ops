module EpoOps
  # Usually this should only used internally.
  # Loads the Hierarchy from the WIPO.
  # This is used to update IpcClassHierarchy manually.
  # At the beginning of the year the WIPO publishes a new list of IPC classes.
  # The IpcClassHierarchy should then be updated. Make sure that the url is
  # correct!
  class IpcClassHierarchyLoader
    # loads data from the WIPO
    # @return [Hash]
    def self.load
      load_url
    end

    private

    def self.load_url
      url = 'http://www.wipo.int/ipc/itos4ipc/ITSupport_and_download_area/20160101/IPC_scheme_title_list/EN_ipc_section_#letter_title_list_20160101.txt'

      # There is a file for every letter A-H
      ('A'..'H').inject({}) do |mem, letter|
        # Fetch the file from the server
        response = HTTParty.get(url.gsub('#letter', letter), http_proxyaddr: proxy[:addr], http_proxyport: proxy[:port])
        file = response.body
        mem.merge! process_file(file)
      end
    end

    def self.process_file(file)
      # Process every line (There is a line for every class entry, name and description are separated by a \t)
      file.each_line.inject(Hash.new { |h, k| h[k] = [] }) do |mem, line|
        next if line.to_s.strip.empty?
        ipc_class_generic, _description = line.split("\t")

        # Some entries in the files have the same ipc class, the first line is
        # just some kind of headline, the second is the description we want.
        ipc_class = EpoOps::IpcClassUtil.parse_generic_format(ipc_class_generic)
        if ipc_class.length == 3
          mem[ipc_class[0]] << ipc_class
        elsif ipc_class.length == 4
          mem[ipc_class[0, 3]] << ipc_class
        end
        mem
      end
    end

    def self.proxy
      # configure proxy
      proxy_addr = nil
      proxy_port = nil
      unless ENV['http_proxy'].to_s.strip.empty?
        proxy_addr, proxy_port = ENV['http_proxy'].gsub('http://', '').gsub('/', '').split(':')
      end
      { addr: proxy_addr, port: proxy_port }
    end
  end
end
