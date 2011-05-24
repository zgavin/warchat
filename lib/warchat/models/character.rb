module Warchat
  module Models
    class Character < Warchat::Model
      CLASSES = {1=>'Warrior',2=>'Paladin',3=>'Hunter',4=>'Rogue',5=>'Priest',6=>'Death Knight',7=>'Shaman',8=>'Mage',9=>'Warlock',11=>'Druid'}
      RACES = {1=>'Human',2=>'Orc',3=>'Dwarf',4=>'Night Elf',5=>'Forsaken',6=>'Tauren',7=>'Gnome',8=>'Troll',9=>'Goblin',10=>'Blood Elf',11=>'Draenei',22=>'Worgen'}
      
      class << self
        def online
          all.select &:online?
        end
      end
      
      def initialize data
        super
        @count = 0
      end
      
      def level
        data['l']
      end
      
      def rank
        data['grank']
      end
      
      def klass
        CLASSES[data['c']]
      end
      
      def race
        RACES[data['ra']]
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
      
      def inspect
        "<#{self.class.name} name:#{name.inspect} realm:#{realm.inspect} klass:#{klass.inspect} level:#{level.inspect} race:#{race.inspect}>"
      end
    end
  end
end