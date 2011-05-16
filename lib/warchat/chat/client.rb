module Warchat
  module Chat
    class Warchat::Chat::Client
      attr_accessor :on_message,:on_presence,:on_logout,:on_fail,:on_establish
      attr_accessor :on_message_afk,:on_message_dnd,:on_message_guild_chat,:on_message_motd,:on_message_officer_chat,:on_message_whisper,:on_chat_logout
      attr_accessor :character_name,:character_realm
      
      attr_reader :session

      def initialize
        @session = Warchat::Network::Session.new

        [:receive,:establish,:error].each do |m| 
          session.send("on_#{m}=".to_sym, method("session_#{m}".to_sym)) 
        end
      end
      
      def start username, password
        self.session.start(username,password)
      end

      def session_error response
        on_fail.andand.call(response["body"]) if response.target == "/chat-login"
      end

      def session_establish response
        on_establish.andand.call(response)
      end

      def session_receive response
        send(response.target.gsub('/','').underscore.to_sym,response)
      end
      
      def login
        request = Warchat::Network::Request.new("/chat-login",:options=>{:mature_filter=>'false'},:n=>character_name,:r=>character_realm)
        session.send_request(request)
        @timer = Warchat::Timer.new(120,&method(:keep_alive))
      end

      def logout
        request = Warchat::Network::Request.new('/chat-logout',:chatSessionId=>@chat_session_id)
      end

      def chat_logout response
        puts 'Logged out of chat'
        @timer.andand.stop
        on_chat_logout.andand.call response
        session.close
      end

      def chat_login response
        puts "Logged into chat"
        @chat_session_id = response["chatSessionId"]
      end

      def chat response
        response.extend(ChatResponse)
        if response.ack?
          
        elsif response.message?
          message = Message.new(response)
          on_message.andand.call(message)
          send("on_message_#{message.type}".to_sym).andand.call(message)
        elsif response.presence?
          on_presence.andand.call(Presence.new(response))
        else
          puts "unhandled chat type: #{response.chat_type}"
        end
      end

      def close_nonblock
        request = Warchat::Network::Request.new("/chat-logout",:chatSessionId=>@chat_session_id)
        session.send_request(request)
      end
      
      def close
        close_nonblock
        sleep(0.1) until session.is_closed?
      end

      def keep_alive
        request = Warchat::Network::Request("/ah-mail")
        request["r"] = realm
        request["cn"] = name
        session.send_request(request)
      end

      def message(msg, chat_type = Message.CHAT_MSG_TYPE_GUILD_CHAT)
        request = Warchat::Network::Request.new("/chat-guild",:type=>chat_type,:body=>msg,:chatSessionId=>@chat_session_id)
        session.send_request(request)
      end

      def whisper(msg, char_id)
        request = Warchat::Network::Request.new("/chat-whisper",:to=>char_id,:body=>msg,:chatSessionId=>@chat_session_id)
        session.send_request(request)
      end
    end
  end
end
