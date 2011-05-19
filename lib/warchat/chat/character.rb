module Warchat
  module Chat
    class Character
      class << self
        def find_or_create data
          find(data['n']).tap do |c| c and c.update(data) end or new(data).tap do |c| mutex.synchronize do characters << c end end
        end
        
        def find data
          mutex.synchronize do characters.find do |c| c.name == data['n'] and c.realm = data['r'] end end
        end
        
        def mutex
          @mutex ||= Mutex.new
        end
        
        def characters
          @characters ||= []
        end
        
        def online_characters 
          characters.select &:online?
        end
      end
      
      attr_accessor :data
      
      
      def initialize data
        @data = data
        @count = 0
      end
      
      def update data
        @data = data
      end
      
      def name
        @data['n']
      end
      
      def level
        @data['l']
      end
      
      def realm
        @data['r']
      end
      
      def rank
        @data['grank']
      end
      
      CLASSES = {1=>'Warrio',2=>'Paladin',3=>'Hunter',4=>'Rogue',5=>'Priest',6=>'Death Knight',7=>'Shaman',8=>'Mage',9=>'Warlock',11=>'Druid'}
      def klass
        CLASSES[@data['c']]
      end
      
      RACES = {1=>'Human',2=>'Orc',3=>'Dwarf',4=>'Night Elf',5=>'Forsaken',6=>'Tauren',7=>'Gnome',8=>'Troll',9=>'Goblin',10=>'Blood Elf',11=>'Draenei',22=>'Worgen'}
      def race
        RACES[@data['ra']]
      end
      
      def == other
        other.is_a? Character and other.name == name or false
      end
        
      def online?
        count > 0 
      end
      
      def online
        @count += 1
      end
      
      def offline
        @count -= 1
      end
    end
  end
end