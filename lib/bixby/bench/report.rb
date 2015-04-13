
module Bixby
  class Bench
    class Report
      attr_accessor :tms, :allocation_stats

      def initialize(bench)
        @bench = bench
      end

      def to_s
        if @allocation_stats then
          format = Benchmark::FORMAT.gsub(/\n$/, '') + " %16d %12d\n"
          allocations = allocation_stats.allocations.all.size
          memsize = allocation_stats.allocations.bytes.to_a.inject(&:+)
          return @tms.format(format, allocations, memsize)
        else
          return @tms
        end
      end

      def print
        @bench.puts self.to_s
      end

    end
  end
end
