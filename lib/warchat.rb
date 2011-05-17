require 'active_support/inflector'

module Warchat  
end

[['*.rb'],['network','*.rb'],['srp','*.rb'],['chat','*.rb']].each do |p| Dir.glob(File.join(File.expand_path('../warchat',__FILE__),*p)).each &method(:require) end
