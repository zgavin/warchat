# encoding: ASCII-8BIT
module Warchat
  module Chat
    class Presence    
      STATUS_OFFLINE = 'offline'
      STATUS_ONLINE = 'online'
      
      def initialize response
        @response = response
        @type = response["presenceType"]
      end
      
      def character
        @character ||= Character.new @response["character"]
      end
      
      def name
        character.name
      end

      def offline?
        @type and @type.include? 'offline'
      end
      
      def status 
        return 'unknown' unless @type
        @type.split('_').first
      end

      def client_type 
        return 'unknown' unless @type
        @type.split('_')[1..-1].join '_'
      end
      
      def inspect
        "<#{self.class.name} name:#{name.inspect} character:#{character.inspect} type:#{type.inspect}>"
      end
    end
  end
end
