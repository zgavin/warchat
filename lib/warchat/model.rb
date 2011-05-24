module Warchat
  class Model
    class << self
      def find_or_create data
        find(data).tap do |m| m and m.update(data) end or new(data)
      end
  
      def find data
        realm,name = data['r'],data['n']
        mutex.synchronize do all[realm] and all[realm][name] or nil end
      end
  
      def mutex
        @mutex ||= Mutex.new
      end
  
      def all
        @all ||= {}
      end
      
      private      
      def add m
        mutex.synchronize do 
          all[m.realm] ||= {}
          all[m.realm][m.name] and all[m.realm][m.name].update(m.data) or all[m.realm][m.name] = m
        end
      end
    end
    
    attr_accessor :data

    def initialize data
      @data = data
      self.class.send(:add,self)
    end
    
    def id 
      [self.class.name.underscore,name,realm].join ':'
    end
    
    def update data
      @data = @data.merge data
    end
    
    def name
      data['n']
    end
    
    def realm
      data['r']
    end
  end
end