# encoding: ASCII-8BIT
module Warchat
  module Chat
    class Presence
      STATUS_OFFLINE = 'offline'
      STATUS_ONLINE = 'online'
      
      def initialize response
        @response = response
        @type = response["presenceType"]

        character.respond_to? status.to_sym and character.send status.to_sym
        
      end
      
      def character
        @character ||= (@response["character"] and Warchat::Models::Character.find_or_create(@response["character"]) or nil)
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
        "<#{self.class.name} character:#{character.inspect} status:#{status.inspect} client_type:#{client_type.inspect}>"
      end
    end
  end
end
