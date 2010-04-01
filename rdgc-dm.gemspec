# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rdgc-dm}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["parrot_studio"]
  s.date = %q{2010-04-01}
  s.description = %q{    This gem is part of RDGC - Ruby(Random) Dungeon Game Core.
    RDGC is core of random dungeon game (like rogue), make dungeon, manage monsters etc.
}
  s.email = %q{parrot@users.sourceforge.jp}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/rdgc-dm.rb",
     "lib/rdgc/maker/divide_dungeon_maker.rb",
     "lib/rdgc/maker/divide_temp_block.rb",
     "lib/rdgc/maker/dungeon_maker.rb",
     "lib/rdgc/maker/temp_block.rb",
     "lib/rdgc/map/area.rb",
     "lib/rdgc/map/block.rb",
     "lib/rdgc/map/board.rb",
     "lib/rdgc/map/road.rb",
     "lib/rdgc/map/room.rb",
     "lib/rdgc/map/tile.rb",
     "lib/rdgc/map/tile_type.rb",
     "lib/rdgc/util/config.rb",
     "lib/rdgc/util/random_util.rb",
     "rdgc-dm.gemspec",
     "spec/rdgc/maker/01_temp_block_spec.rb",
     "spec/rdgc/maker/02_divide_temp_block_spec.rb",
     "spec/rdgc/maker/03_divide_dungeon_maker_divide_spec.rb",
     "spec/rdgc/maker/04_divide_dungeon_maker_create_spec.rb",
     "spec/rdgc/map/01_tile_spec.rb",
     "spec/rdgc/map/02_area_spec.rb",
     "spec/rdgc/map/03_road_spec.rb",
     "spec/rdgc/map/04_room_spec.rb",
     "spec/rdgc/map/05_block_spec.rb",
     "spec/rdgc/map/06_board_spec.rb",
     "spec/rdgc/util/01_config_spec.rb",
     "spec/rdgc/util/02_random_util_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/parrot-studio/rdgc-dm}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Random Dungeon Maker from RDGC}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/rdgc/util/02_random_util_spec.rb",
     "spec/rdgc/util/01_config_spec.rb",
     "spec/rdgc/map/04_room_spec.rb",
     "spec/rdgc/map/06_board_spec.rb",
     "spec/rdgc/map/01_tile_spec.rb",
     "spec/rdgc/map/03_road_spec.rb",
     "spec/rdgc/map/05_block_spec.rb",
     "spec/rdgc/map/02_area_spec.rb",
     "spec/rdgc/maker/02_divide_temp_block_spec.rb",
     "spec/rdgc/maker/01_temp_block_spec.rb",
     "spec/rdgc/maker/04_divide_dungeon_maker_create_spec.rb",
     "spec/rdgc/maker/03_divide_dungeon_maker_divide_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
  end
end

