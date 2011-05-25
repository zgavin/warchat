# encoding: ASCII-8BIT
module Warchat
  module Chat
    class Message
      CHAT_MSG_TYPE_AFK = "afk"
      CHAT_MSG_TYPE_DND = "dnd"
      CHAT_MSG_TYPE_GUILD_CHAT = "guild_chat"
      CHAT_MSG_TYPE_GUILD_MOTD = "motd"
      CHAT_MSG_TYPE_OFFICER_CHAT = "officer_chat"
      CHAT_MSG_TYPE_WHISPER = "whisper"

      attr_reader :type,:body
      
      def initialize response
        @response = response 
        @type = response["messageType"]
        @body = response['body']
        @from = (response["from"] or {})
      end
      
      def guild
        return @guild if @guild or @from["guildId"].nil?
        _,name,realm = @response['from']["guildId"].split(':')
        @guild = Warchat::Models::Guild.find_or_create 'n' => name,'r'=>realm
      end
      
      def character
        return @character if @character or @from["characterId"].nil?
        _,name,realm = @from["characterId"].split(':')
        @character = Warchat::Models::Character.find_or_create 'n' => name,'r'=>realm
      end
      
      constants.select do |c| c[0..13] == 'CHAT_MSG_TYPE_' end.map do |c| "Warchat::Chat::Message::#{c}" end.each do |c|
        define_method "#{c.constantize}?".to_sym do 
          type == c.constantize
        end
      end
    end
  end
end