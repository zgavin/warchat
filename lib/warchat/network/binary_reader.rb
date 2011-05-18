# encoding: ASCII-8BIT
module Warchat
  module Network
    class BinaryReader
      def initialize socket
        @socket = socket
      end

      TYPES = [:hash,:array,:int_32,:string,:string,:boolean,:int_64]
      def parse_next *args  
        send TYPES[byte.unpack('C').first-1]
      end
      
      def substream l
        sub = @socket.read(l) 
        until sub.length >= l
          sub << @socket.read(l-sub.length)      
        end
        sub
      end

      def byte
        substream(1)
      end

      def string
        substream(int_32)
      end

      def array
        (1..(int_32)).map(&method(:parse_next))
      end

      def hash
        Hash[*(1..(int_32)).map do
          [string,parse_next] 
        end.flatten(1)]
      end

      {16=>'n',32=>'N',64=>'L_'}.each do |size,directive| 
        define_method "int_#{size}".to_sym do 
          substream(size/8).unpack(directive).first
        end 
      end

      def boolean
        byte == "\001"
      end
    end
  end
end