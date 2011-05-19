module Warchat
  module Chat
    class Character
      attr_accessor :data
      
      def initialize data
        @data = data
        @count = 0
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