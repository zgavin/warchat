# encoding: ASCII-8BIT
module Warchat
  module Network
    class Session

      attr_accessor :on_close,:on_receive,:on_establish,:on_error


      def initialize
        @connection = Warchat::Network::Connection.new

        @connection.on_close = method(:connection_close)
        @connection.on_receive = method(:connection_receive)
      end

      def start account_name, account_password,host="m.us.wowarmory.com",port=8780
        @account_name = account_name
        @account_password = account_password

        @connection.start host,port

        @srp = Warchat::Srp::Client.new

        send_request Request.new('/authenticate1',
          :screenRes => "PHONE_HIGH",
          :device => "iPhone",
          :deviceSystemVersion => "4.2.1",
          :deviceModel => "iPhone3,1",
          :appV => "3.0.0",
          :deviceTime => Time.now.to_i,
          :deviceTimeZoneId => "America/New_York",
          :clientA => @srp.a_bytes,
          :appId => "Armory",
          :deviceId => '50862581c5dc46072050d51886cbae3149b3473c',
          :emailAddress => account_name,
          :deviceTimeZone => "-14400000",
          :locale => "en_US"
        )
      end
      
      def established? 
        @established
      end

      def close reason=''
        @connection.close reason
      end
      
      def is_closed?
        @connection.is_closed?
      end
      
      def send_request request
        @connection and @connection.send_request(request)
      end

      def stage_1 response
        proof = @srp.auth1_proof(response["user"], @account_password[0..15].upcase, response["salt"], response["B"])
        send_request(Request.new("/authenticate2",:clientProof=>proof))
      end

      def stage_2 response
        send_request(Request.new("/authenticate2",:clientProof=>Warchat::ByteString.new("\000")))
      end
      
      def stage_3 response
        @established = true 
        on_establish and on_establish.call(response)
      end

      def connection_receive response
        m = "stage_#{response['stage']}".to_sym
        if response.ok?
          respond_to? m and send(m,response) or on_receive and on_receive.call(response)
        else
          error = response["body"]
          Warchat.debug("error: " + error)
          close(error) if respond_to? m
        end      
      end

      def connection_close reason
        on_close and on_close.call(reason)
      end
    end
  end
end