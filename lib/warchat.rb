require 'active_support/inflector'
require 'andand'

module Warchat  
end

[['*.rb'],['network','*.rb'],['srp','*.rb'],['chat','*.rb']].each do |p| Dir.glob(File.join(File.expand_path('../wow_chat',__FILE__)),*p)).each &method(:require) end
