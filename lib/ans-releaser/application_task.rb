# -*- coding: utf-8 -*-

module Ans::Releaser::ApplicationTask
  include Rake::DSL if defined? Rake::DSL
  include Ans::Releaser::ReleaseHelper

  def stages
    [:release,:staging]
  end

  def version_file
    "config/initializers/version.rb"
  end
  def version
    require "config/initializers/version"
    application.const_get("VERSION")
  end

  def perform_release(stage)
    git_pull
    guard_clean
    guard_already_tagged stage
    gem_path = build_gem
    tag_version stage {
      git_push
      deploy
    }
  end

  def deploy(stage)
    cap_stage = stage
	  cap_stage = "production" if stage == :release
    sh "sh -c 'RELEASE_TAG=#{version_tag stage} cap #{stage} deploy:update'"
  end

end
