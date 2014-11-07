
module Bixby
  class Bench
    class Report
      attr_accessor :tms, :allocation_stats

      def print
        if @allocation_stats then
          format = Benchmark::FORMAT.gsub(/\n$/, '') + " %16d %12d\n"
          allocations = allocation_stats.allocations.all.size
          memsize = allocation_stats.allocations.bytes.to_a.inject(&:+)
          puts @tms.format(format, allocations, memsize)
        else
          puts @tms
        end
      end
    end
  end
end
