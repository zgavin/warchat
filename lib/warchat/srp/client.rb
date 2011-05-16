require 'digest'
require 'openssl'

module Warchat
  module Srp
    class Client
      G = 2

      MODULUS_SIZE = 128
      MODULUS = 0x86a7f6deeb306ce519770fe37d556f29944132554ded0bd68205e27f3231fef5a10108238a3150c59caf7b0b6478691c13a6acf5e1b5adafd4a943d4a21a142b800e8a55f8bfbac700eb77a7235ee5a609e350ea9fc19f10d921c2fa832e4461b7125d38d254a0be873dfc27858acb3f8b9f258461e4373bc3a6c2a9634324ab

      SALT_SIZE = 32
      HASH_SIZE = 32
      SESSION_KEY_SIZE = HASH_SIZE * 2

      attr_reader :b,:b_bytes

      def modpow(a, n, m) 
        r = 1
        while true
          r = r * a % m if n[0] == 1
          n >>= 1
          return r if n == 0
          a = a * a % m
        end
      end

      def pack_int int
        Warchat::ByteString.new [int.to_s(16).reverse].pack('h*')
      end
      
      def unpack_int str
        str.unpack('h*').first.reverse.hex
      end
      
      def digest_int s
        unpack_int(Digest::SHA2.digest(s))
      end
      
      def adjust_size str,length
        str[0..(length-1)].ljust(length,"\000")
      end

      def random_crypt
        unpack_int(OpenSSL::Random.random_bytes(MODULUS_SIZE*2)) % MODULUS
      end
      
      def hN_xor_hG
        # xor H(N) and H(G)
        return @hN_xor_hG if @hN_xor_hG
        hN = Digest::SHA2.digest(pack_int(MODULUS))
        hG = Digest::SHA2.digest(pack_int(G))
        
        @hN_xor_hG = "\000" * HASH_SIZE
        
        HASH_SIZE.times do |i| @hN_xor_hG[i] = (hN[i] ^ hG[i]) end
          
        @hN_xor_hG
      end

      def a
        @a ||= random_crypt
      end

      def a_bytes 
        @a_bytes ||= adjust_size(pack_int(modpow(G,a,MODULUS)),MODULUS_SIZE)
      end

      def k
        @k ||= digest_int(pack_int(MODULUS)+pack_int(G))
      end

      def u 
        # H(A | B)
        @u ||= digest_int(a_bytes+b_bytes)
      end

      def x
        # H(salt | H(userHash | : | sessionPassword))
        @x ||= digest_int(@salt+Digest::SHA2.digest(@user+":"+@password))
      end

      def s
        # (B - k * G^x) ^ (a + u * x)
        return modpow(b - k * modpow(G, x, MODULUS), a + u * x, MODULUS)
      end

      def s_bytes
        @s_bytes ||= adjust_size(pack_int(s),(MODULUS_SIZE))
      end


      def auth1_proof user, password, salt, b_bytes
        @b = unpack_int b_bytes
        @b_bytes = adjust_size(b_bytes,MODULUS_SIZE)
        @salt = adjust_size(salt,SALT_SIZE)
        @user = user
        @password = password

        # hash this to generate client proof, H(H(N) xor H(G) | H(userHash) | salt | A | B | K)
        Warchat::ByteString.new Digest::SHA2.digest(hN_xor_hG+Digest::SHA2.digest(@user)+salt+a_bytes+@b_bytes+session_key)
      end

      def session_key
        return @session_key if @session_key
        @session_key = "\000" * SESSION_KEY_SIZE

        l = s_bytes.length
        offset = (l.odd? and 1 or 0)
        l -= offset

        l = [l/2,MODULUS_SIZE].min

        temp = ''
        l.times do |i|
          temp << s_bytes[i*2+offset]
        end

        hash = Digest::SHA2.digest(temp)
        HASH_SIZE.times do |i|
          @session_key[i*2] = hash[i]
        end

        temp = ''
        l.times do |i|
          temp << s_bytes[i*2+offset+1]
        end

        hash = Digest::SHA2.digest(temp)
        HASH_SIZE.times do |i|
          @session_key[i*2+1] = hash[i]
        end

        @session_key
      end
    end
  end
end