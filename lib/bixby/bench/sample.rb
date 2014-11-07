
module Bixby
  class Bench
    class Sample

      attr_reader :label, :block

      def initialize(label, block, sample_size, memory)
        @label       = label
        @block       = block
        @sample_size = sample_size
        @memory      = memory
      end

      def call
        @block.call
      end

      def measure
        report = Report.new
        report.tms = Benchmark.measure { @sample_size.times { self.call } }

        if @memory then
          report.allocation_stats = AllocationStats.new(burn: 5).trace { self.call }
        end

        return report
      end

    end
  end
end
