module Warchat
  module Network
    class BinaryWriter

      attr_reader :stream

      def initialize stream
        @stream = stream
      end

      def write obj
        m = (obj.class.ancestors.map do |c| 
          "write_#{File.basename c.name.underscore}".to_sym 
        end.find(&method(:respond_to?)) or :write_string)
        send(m,obj)
      end

      def write_string obj
        byte 5
        string obj.to_s
      end

      def write_integer obj
        if obj < 2**32
          byte 3
          int_32 obj
        else
          byte 7
          int_64 obj 
        end
      end

      def write_hash obj
        byte 1
        int_32 obj.size
        obj.each do |k,v|
          string(k.to_s)
          write(v)
        end
      end

      def write_array obj
        byte 2
        int_32 obj.size
        obj.each do |v|
          write(v)
        end
      end

      def write_byte_string obj
        byte 4
        int_32 obj.length
        bytes obj
      end

      def write_bool obj
        byte 6
        byte(obj ? 1 : 0)
      end
      alias_method :write_true_class,:write_bool
      alias_method :write_false_class,:write_bool


      {16=>'n',32=>'N',64=>'L_'}.each do |size,directive|
        define_method "int_#{size}".to_sym do |obj| 
          @stream.print [obj].pack(directive)
        end 
      end

      def string obj
        obj = obj.to_s
        int_32 obj.length
        @stream.print obj
      end

      def byte obj
        obj = (obj.is_a? Integer and [obj].pack('C') or obj.to_s[0..0])
        @stream.print obj
      end

      def bytes obj
        @stream.print obj.to_s
      end
    end  
  end
end