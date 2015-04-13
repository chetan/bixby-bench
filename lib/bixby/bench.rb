
require "benchmark"
require "allocation_stats"

require "bixby/bench/divider"
require "bixby/bench/sample"
require "bixby/bench/report"
require "bixby/bench/middleware"
require "bixby/bench/long_running_bench"

module Bixby
  class Bench

    # Run a benchmark
    #
    # @param [Fixnum] sample_size       number of samples to take
    # @param [Boolean] memory           whether or not to measure memory allocation
    #
    # @return [Bench] bench             instance which was created, after all benchmarks have run
    def self.run(sample_size, memory=true, io=STDOUT)
      bench = Bench.new(sample_size, memory, io)
      yield(bench)

      # now that we have all samples, run the thing
      bench.sync_io { bench.run_all }

      bench
    end

    def sync_io
      begin
        old_sync = @io.sync
        @io.sync = true
        yield
      ensure
        @io.sync = old_sync unless old_sync.nil?
      end
    end

    def initialize(sample_size, memory=true, io=STDOUT)
      @sample_size = sample_size
      @memory = memory
      @samples = []
      @io = io
    end

    # Add a sample to be tested
    #
    # @param [String] label          a short name for the sample being tested
    # @param [Block] block           the code to be measured
    def sample(label, &block)
      @samples << Sample.new(self, label, block, @sample_size, @memory)
    end
    alias_method :report, :sample

    # Add a divider to the output
    def divider
      @samples << Divider.new(self)
    end
    alias_method :add_divider, :divider

    def print(str)
      @io.print(str)
    end

    def puts(str)
      print(str+"\n")
    end

    # Calculate the label padding, taking all labels into account
    def label_width
      if !@label_width then
        @label_width = @samples.find_all{ |s| Sample === s }.
                          max{ |a, b| a.label.length <=> b.label.length }.
                          label.length + 1

        @label_width = 40 if @label_width < 40
      end

      return @label_width
    end

    # Calculate the divider width
    def divider_width
      @divider_width ||= (label_width + (@memory ? 75 : 45))
    end

    def print_header
      caption = Benchmark::CAPTION
      if @memory then
        caption = caption.gsub(/\n$/, '') + "       allocations      memsize\n"
      end
      print ' '*label_width + caption
    end

    def run_all
      print_header

      @samples.each do |sample|
        if Divider === sample then
          sample.print(divider_width)
          next
        end

        print sample.label.ljust(label_width)
        sample.measure.print
      end
    end

  end
end
