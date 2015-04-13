
require "thread"

module Bixby
  class Bench
    class LongRunningBench < Bench

      def initialize(sample_size, memory, io)
        super
        @num = 0
        @mutex = Mutex.new
      end

      def sample(label, &block)

        sample = Sample.new(self, label, block, @sample_size, @memory)
        report = sample.measure()

        @mutex.synchronize {
          @samples.clear
          @samples << sample
          print_header if @num % 100 == 0
          self.print(sample.label.ljust(label_width) + report.to_s)
          @num += 1
          @samples.clear
        }

      end

    end
  end
end
