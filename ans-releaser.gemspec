# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ans-releaser/version"

Gem::Specification.new do |s|
  s.name        = "ans-releaser"
  s.version     = Ans::Releaser::VERSION
  s.authors     = ["sakai shunsuke"]
  s.email       = ["sakai@ans-web.co.jp"]
  s.homepage    = "https://github.com/answer/ans-releaser"
  s.summary     = %q{リリースタスクを提供する}
  s.description = %q{gem やアプリケーションをリリースするときのタスクを提供する}

  s.rubyforge_project = "ans-releaser"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "bundler"
  s.add_runtime_dependency "rake"
end
