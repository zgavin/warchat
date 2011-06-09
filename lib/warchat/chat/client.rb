# encoding: ASCII-8BIT
module Warchat
  module Chat
    class Client
      attr_accessor :on_message,:on_presence,:on_logout,:on_fail,:on_establish,:on_presence_change,:on_ack
      attr_accessor :on_message_afk,:on_message_dnd,:on_message_guild_chat,:on_message_motd,:on_message_officer_chat,:on_message_whisper,:on_chat_logout
      
      attr_reader :session,:character_name,:character_realm,:online_characters,:last_whisper

      def initialize
        @session = Warchat::Network::Session.new
        [:receive,:establish,:error].each do |m| 
          session.send("on_#{m}=".to_sym, method("session_#{m}".to_sym)) 
        end
      end
      
      def start account_name, account_password,host="m.us.wowarmory.com",port=8780
        [account_name,account_password].each do |s| s.respond_to? :force_encoding and s.force_encoding(__ENCODING__) end
        self.session.start(account_name,account_password,host,port)
      end

      def session_error response
        on_fail and on_fail.call(response["body"]) if response.target == "/chat-login"
      end

      def session_establish response
        on_establish and on_establish.call(response)
      end

      def session_receive response
        m = response.target.gsub('/','').underscore.to_sym
        send(m,response) if respond_to? m
      end
      
      def login *args
        @character_name,@character_realm = args
        [character_name,character_realm].each do |s| s.respond_to? :force_encoding and s.force_encoding(__ENCODING__) end
        request = Warchat::Network::Request.new("/chat-login",:options=>{:mature_filter=>'false'},:n=>character_name,:r=>character_realm)
        session.send_request(request)
        @timer = Warchat::Timer.new(60) do keep_alive end
      end

      def logout
        request = Warchat::Network::Request.new('/chat-logout',:chatSessionId=>@chat_session_id)
      end

      def chat_logout response
        Warchat.debug 'Logged out of chat'
        @timer and @timer.stop
        on_chat_logout and on_chat_logout.call response
        session.close
      end

      def chat_login response
        Warchat.debug "Logged into chat"
        @chat_session_id = response["chatSessionId"]
      end
      
      def chat_presence presence
        on_presence and on_presence.call(presence)
      end

      def chat response
        response.extend(Warchat::Chat::ChatResponse)
        if response.ack?
          on_ack and on_ack.call response
        elsif response.message?
          message = Warchat::Chat::Message.new(response)
          @last_whisper = message if message.whisper?
          [on_message,send("on_message_#{message.type}".to_sym)].compact.each do |m| m.call(message) end
        elsif response.presence?
          chat_presence Warchat::Chat::Presence.new(response)
        else
          Warchat.debug "unhandled chat type: #{response.chat_type}"
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
        Warchat.debug 'keep alive'
        request = Warchat::Network::Request.new("/ah-mail",:n=>character_name,:r=>character_realm)
        session.send_request(request)
      end

      def message(msg, chat_type = Message.CHAT_MSG_TYPE_GUILD_CHAT)
        request = Warchat::Network::Request.new("/chat-guild",:type=>chat_type,:body=>msg,:chatSessionId=>@chat_session_id)
        session.send_request(request)
      end

      def whisper(msg, name)
        request = Warchat::Network::Request.new("/chat-whisper",:to=>"character:#{name}:#{character_realm.downcase}",:body=>msg,:chatSessionId=>@chat_session_id)
        session.send_request(request)
      end
    end
  end
end
