# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rdgc-dm/version"

Gem::Specification.new do |s|
  s.name        = "rdgc-dm"
  s.version     = Rdgc::Dm::VERSION
  s.authors     = ["parrot_studio", "parrot-studio"]
  s.email       = ["parrot@users.sourceforge.jp", "parrot.studio.dev@gmail.com"]
  s.homepage    = "http://github.com/parrot-studio/rdgc-dm"
  s.summary     = %q{Random Dungeon Maker from RDGC}
  s.description = %q{
    This gem is part of RDGC - Ruby(Random) Dungeon Game Core.
    RDGC is core of random dungeon game (like rogue), make dungeon, manage monsters etc.
  }

  s.rubyforge_project = "rdgc-dm"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
