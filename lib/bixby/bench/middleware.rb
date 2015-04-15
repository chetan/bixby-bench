
require "thread"

module Bixby
  class Bench

    class ThreadWriter

      extend Forwardable
      def_delegators :@fh, :sync, :sync=

      def initialize(fh)
        @fh = fh
        @queue = Queue.new
        start()
      end

      def start
        Thread.new do
          begin
            while true
              msg = @queue.pop
              @fh.print(msg)
              @fh.fsync
            end
          rescue Exception => ex
            puts ex
            puts ex.backtrace
          end
        end
      end

      def print(str)
        @queue.push(str)
      end
    end

    class Middleware

      include Bixby::Log

      def initialize(app, logfile=nil)
        @app = app

        # set log path
        @logfile = if logfile then
          logfile
        elsif Module.const_defined? :Rails then
          File.join(Rails.root, "log", "bench.log")
        elsif ENV["BUNDLE_GEMFILE"] then
          File.join(File.dirname(ENV["BUNDLE_GEMFILE"]), "bench.log")
        else
          "bench.log"
        end

        @logfile = File.expand_path(@logfile)
        STDERR.puts "Writing benchmark log to #{@logfile}"

      end

      def call(env)
        @fh ||= ThreadWriter.new(File.open(@logfile, 'a+'))
        @bench ||= LongRunningBench.new(1, true, @fh)

        path = env["REQUEST_URI"]
        if path =~ /\.(js|css|png|gif|jpg)$/ then
          # pass thru calls to static resources
          return @app.call(env)
        end

        ret = nil
        begin
          @bench.sample(path) {
            ret = @app.call(env)
          }
        rescue => ex
          puts "#{self.class.name} caught ex: #{ex.message}"
          puts ex.backtrace
        end

        return ret
      end

    end
  end
end
