module EpoOps
  # Utility functions to work on Strings representing ipc classes.
  class IpcClassUtil

    # @return [Array] \['A', 'B', …, 'H'\]
    def self.main_classes
      %w( A B C D E F G H )
    end

    # check if the given ipc_class is valid as OPS search parameter
    # @param [String] ipc_class an ipc class
    # @return [Boolean]
    def self.valid_for_search?(ipc_class)
      ipc_class.match(/\A[A-H](\d{2}([A-Z](\d{1,2}\/\d{2,3})?)?)?\z/)
    end

    # There is a generic format for ipc classes that does not have
    # the / as delimiter and leaves space for additions. This parses
    # it into the format the register search understands
    # @param [String] generic ipc class in generic format
    # @return [String] reformatted ipc class
    # @example
    #   parse_generic_format('A01B0003140000') #=> 'A01B3/14'
    def self.parse_generic_format(generic)
      ipc_class = generic
      if ipc_class.length > 4
        match = ipc_class.match(/([A-Z]\d{2}[A-Z])(\d{4})(\d{6})$/)
        ipc_class = match[1] + (match[2].to_i).to_s + '/' + process_number(match[3])
      end
      ipc_class
    end

    # @param [String] ipc_class an ipc_class
    # @return [Array] List of all ipc classes one level more specific.
    # @example
    #   children('A')   #=> ['A01', 'A21', 'A22', 'A23', ...]
    #   children('A62') #=> ['A62B', 'A62C', 'A62D'],
    # @raise [InvalidIpcClassError] if parameter is not a valid ipc class in
    #   the format EPO understands
    # @raise [LevelNotSupportedError] for parameters with ipc class depth >= 3
    #   e.g. 'A62B' cannot be split further. It is currently not necessary to
    #   do so, it would only blow up the gem, and you do not want to query for
    #   all classes at the lowest level, as it takes too many requests.
    def self.children(ipc_class)
      return main_classes if ipc_class.nil?
      valid = valid_for_search?(ipc_class)
      fail InvalidIpcClassError, ipc_class unless valid
      map = IpcClassHierarchy::Hierarchy
      fail LevelNotSupportedError, ipc_class unless map.key? ipc_class
      map[ipc_class]
    end

    # An ipc class in invalid format was given, or none at all.
    class InvalidIpcClassError < StandardError; end
    # It is currently not supported to split by the most specific class level.
    # This would result in a large amount of requests.
    class LevelNotSupportedError < StandardError; end

    private

    def self.process_number(number)
      result = number.gsub(/0+$/, '')
      result += '0' if result.length == 1
      result = '00' if result.length == 0

      result
    end
  end
end
