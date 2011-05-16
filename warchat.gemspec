# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "warchat/version"

Gem::Specification.new do |s|
  s.name        = "warchat"
  s.version     = Warchat::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Zachary Gavin"]
  s.email       = ["zgavin@gmail.com"]
  s.homepage    = "http://www.github.com/zgavin/warchat"
  s.summary     = %q{A simple interface to World of Warcraft Remote Guild Chat}
  s.description = %q{A simple interface to World of Warcraft Remote Guild Chat}

  s.rubyforge_project = "warchat"
  
  s.add_dependency('activesupport','>= 3.0.0')
  s.add_dependency('andand')
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
