module Epo
  module Ops
    # Simple logger writing some notifications to standard output.
    class Logger
      # Just hands the parameter to puts.
      def self.log(output)
        puts output
      end

      # Debug logging only
      def self.debug(output)
        log(output) if ENV['DEBUG']
      end

    end
  end
end
