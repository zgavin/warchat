module Warchat
  module Chat
    class Message
      CHAT_ID_TYPE_CHARACTER = "character"
      CHAT_ID_TYPE_GUILD = "guild"
      CHAT_ID_TYPE_GUILD_MEMBER = "guild_member"

      CHAT_MSG_TYPE_AFK = "afk"
      CHAT_MSG_TYPE_DND = "dnd"
      CHAT_MSG_TYPE_GUILD_CHAT = "guild_chat"
      CHAT_MSG_TYPE_GUILD_MOTD = "motd"
      CHAT_MSG_TYPE_OFFICER_CHAT = "officer_chat"
      CHAT_MSG_TYPE_WHISPER = "whisper"

      attr_reader :type,:body,:from_type,:character_id,:from
      
      def initialize response
        @type = response["messageType"]
        @body = response['body']
        @from = response["from"]
        if @from
          @from_type = from["chatIdType"]
          @character_id = from["characterId"]
        end
      end

      def character_name
        @character_id and @character_id.split(':')[-2]
      end

      def realm_id
        @character_id and @character_id.split(':').last
      end
    end
  end
end