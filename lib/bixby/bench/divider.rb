
module Bixby
  class Bench
    class Divider

      def initialize(bench)
        @bench = bench
      end

      def print(width)
        @bench.puts '-'*width
      end

    end
  end
end
