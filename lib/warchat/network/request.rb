module Warchat
  module Network
    class Request < Hash
      class StringSocket
        def initialize
          @stream = ""
        end
        
        def print obj
          @stream << obj.to_s
        end
        
        def length
          @stream.length
        end
        
        def value
          @stream
        end
      end
      attr_reader :id,:target

      def initialize target,*args
        @target = target
        @@request_count ||= -1
        @@request_count += 1
        @id = @@request_count
        merge! args.shift if args.first.is_a? Hash
        super *args
      end

      def stream socket
        writer = BinaryWriter.new socket
        writer.string(target)
        writer.int_32(@id)
        each do |k,v|
          if [Hash,Array,Warchat::ByteString].none? &v.method(:is_a?)
            writer.byte 5
            writer.string k
            writer.string v.to_s
          else
            writer.byte 4
            writer.string k
            tmp_socket = StringSocket.new
            tmp = BinaryWriter.new(tmp_socket)
            tmp.write v
            writer.int_32(tmp_socket.length)        
            writer.bytes(tmp_socket.value)
          end
          writer.byte 0xFF
        end
        writer.byte 0xFF
      end
      
      def inspect
        "<#{self.class.name} id:#{id.inspect} target:#{target.inspect} #{super}>"
      end
    end  
  end
end