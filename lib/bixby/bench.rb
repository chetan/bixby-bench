
require "benchmark"
require "allocation_stats"

require "bixby/bench/divider"
require "bixby/bench/sample"
require "bixby/bench/report"

module Bixby
  class Bench

    def self.run(sample_size, memory=true)
      bench = Bench.new(sample_size, memory)
      yield(bench)

      # now that we have all samples, run the thing
      sync_stdout { bench.run_all }

      bench
    end

    def self.sync_stdout
      begin
        old_sync = STDOUT.sync
        STDOUT.sync = true
        yield
      ensure
        STDOUT.sync = old_sync unless old_sync.nil?
      end
    end

    def initialize(sample_size, memory=true)
      @sample_size = sample_size
      @memory = memory
      @samples = []
    end

    def sample(label, &block)
      @samples << Sample.new(label, block, @sample_size, @memory)
    end
    alias_method :report, :sample

    def divider
      @samples << Divider.new
    end
    alias_method :add_divider, :divider

    def label_width
      if !@label_width then
        @label_width = @samples.find_all{ |s| Sample === s }.
                          max{ |a, b| a.label.length <=> b.label.length }.
                          label.length + 1

        @label_width = 40 if @label_width < 40
      end

      return @label_width
    end

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
