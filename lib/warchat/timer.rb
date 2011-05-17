require 'monitor'

module Warchat  
  class Timer
    def initialize(interval, &handler)
      
      raise ArgumentError, "Illegal interval" if interval < 0
      @interval = interval
      extend MonitorMixin
      @run = true
      @th = Thread.new do
        while run?
          if do_sleep 
            begin
              handler.call
            rescue Exception => e
              puts e.message
              puts e.backtrace
            end
          end
        end
      end
      @th['name'] = 'Timer'
    end

    def stop
      synchronize do
        @run = false
      end
      sleeping? and @th.kill or @th.join 
    end

    private
    
    def sleeping?
      synchronize do @sleeping end
    end
    
    def do_sleep
      synchronize do @sleeping = true end
      sleep(@interval)
    rescue
      nil
    ensure
      synchronize do @sleeping = false end
    end

    def run?
      synchronize do
        @run
      end
    end
  end
end