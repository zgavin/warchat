module Warchat
  module Network
    class Response < Hash
      attr_accessor :length,:status,:target,:id
      def initialize socket,*args
        super *args
        reader = BinaryReader.new socket
        self.length = reader.int_32
        self.status = reader.int_16
        self.target = reader.string
        self.id = reader.int_32

        merge! reader.parse_next
      end

      def ok?
        status == 200
      end
      
      def inspect
        "<#{self.class.name} id:#{id.inspect} target:#{target.inspect} status:#{status.inspect} #{super}>"
      end
    end
  end
end