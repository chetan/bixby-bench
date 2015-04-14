
require "thread"

module Bixby
  class Bench

    class ThreadWriter

      include Bixby::Log
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

      def initialize(app)
        @app = app
      end

      def call(env)
        @fh ||= ThreadWriter.new(File.open(File.join(Rails.root, "log", "bench.log"), 'a+'))
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
