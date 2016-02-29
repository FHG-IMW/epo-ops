module Epo
  module Ops
    # Simple logger writing some notifications to standard output.
    class Logger
      # Just hands the parameter to puts.
      def self.log(output)
        puts output
      end
    end
  end
end
