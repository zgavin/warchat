# encoding: ASCII-8BIT
module Warchat  
  module Chat
    module ChatResponse
      def presence?
        chat_type == 'wow_presence'
      end

      def ack?
        chat_type == 'message_ack'
      end

      def message? 
        chat_type == 'wow_message'
      end

      def chat_type
        self['chatType']
      end
    end
  end
end