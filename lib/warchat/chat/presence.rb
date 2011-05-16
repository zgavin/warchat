module Warchat
  module Chat
    class Presence    
      attr_reader :name,:character

      def initialize response
        @type = response["presenceType"];
        @character = response["character"];
        @name = character["n"];
      end

      def offline?
        @type.andand.include? 'offline'
      end

      def type 
        return 'unknown' unless @type
        @type.split('_')[1..-1].join '_'
      end
    end
  end
end
