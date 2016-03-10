require 'httparty'
require 'yaml'
require 'core_ext'
require 'epo/ops/ipc_class_util'

module Epo
  module Ops
    # Creates a Hash that helps using the ipc class hierarchy. The hash is
    # either parsed from a given file directly, or created from data from the
    # WIPO.
    # Usually this should only used internally.
    class IpcClassHierarchyLoader
      # Checks if the given file exists then loads it, otherwise creates it with
      # data from the WIPO
      def self.load(filename)
        if File.exist? filename
          map = load_file(filename)
        else
          map = load_url
          dump_file(map, filename)
        end
        map
      end

      private

      def self.load_file(filename)
        Psych.load_file(filename)
      end

      def self.dump_file(content, filename)
        File.open(filename, 'w') do |file|
          file.write(Psych.dump(content))
        end
      end

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
          next if line.blank?
          ipc_class_generic, description = line.split("\t")

          # Some entries in the files have the same ipc class, the first line is
          # just some kind of headline, the second is the description we want.
          ipc_class = Epo::Ops::IpcClassUtil.parse_generic_format(ipc_class_generic)
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
        unless ENV['http_proxy'].blank?
          proxy_addr, proxy_port = ENV['http_proxy'].gsub('http://', '').gsub('/', '').split(':')
        end
        { addr: proxy_addr, port: proxy_port }
      end
    end
  end
end
