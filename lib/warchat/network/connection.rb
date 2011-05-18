# encoding: ASCII-8BIT
require 'socket'
require 'thread'

module Warchat
  module Network
    class Connection

      attr_accessor :host,:port,:on_send,:on_receive,:on_close

      def initialize *args
        options = args.pop if args.last.is_a? Hash

        self.host = (args.shift or "m.us.wowarmory.com")
        self.port = (args.shift or 8780)
        @closed = true
        @queue = []
        @mutex = Mutex.new
      end

      def start
        close

        @closed = false;
        @socket = TCPSocket.open(host,port)
        @socket.sync = false
        @request_thread = Thread.new &method(:handle_requests)
        @response_thread = Thread.new &method(:handle_responses)
        @request_thread['name'] = 'Request Thead'
        @response_thread['name'] = 'Response Thread'
      end

      def close reason = ""
        return if is_closed?

        on_close and on_close.call(reason)
        
        @mutex.synchronize do 
          @closed = true
          @socket.close
        end     
        ([@request_thread,@response_thread]-[Thread.current]).each &:join
      end

      def is_closed? 
        @closed or @socket.nil?
      end

      def send_request request
        @mutex.synchronize do
          @queue << request
        end
      end

      def handle_responses
        until is_closed?
          response = Response.new(@socket)
          on_receive and on_receive.call(response) unless is_closed?
          sleep 0.01
        end
      rescue Exception => e
        Warchat.debug e.message
        Warchat.debug e.backtrace unless e.is_a? IOError
      end

      def handle_requests
        until is_closed?
          @mutex.synchronize do
            until @queue.empty?
              request = @queue.shift
              unless is_closed?
                request.stream @socket
                @socket.flush
                on_send and on_send.call(request) 
              end
            end
          end
          sleep 0.01
        end
      rescue Exception => e
        Warchat.debug e.message
        Warchat.debug e.backtrace
      end
    end
  end
end