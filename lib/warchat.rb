# encoding: ASCII-8BIT
require 'active_support/all'

module Warchat  
  def self.debug message
    puts message if self.debug?
  end
  
  def self.debug?
    @debug and true or false
  end
  
  def self.enable_debug v
    @debug = v
  end
end

[[],['network'],['srp'],['chat'],['models']].each do |p| Dir.glob(File.join(File.expand_path('../warchat',__FILE__),*(p << '*.rb')),&method(:require)) end
