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
    load version_file
    application.const_get("VERSION")
  end
  def version_message(stage)
    " by #{stage} ( #{branch} )"
  end
  def version_tag_suffix(stage)
    "-#{stage}.#{branch}"
  end
  def branch
    `git symbolic-ref HEAD`.gsub(%r{^refs/heads/}, "").strip
  end

  def perform_release(stage)
    git_pull
    guard_clean
    guard_already_tagged stage
    tag_version(stage){
      git_push
      deploy stage
    }
  end

  def deploy(stage)
    sh "sh -c 'RELEASE_TAG=#{version_tag stage} cap #{deploy_stage stage} deploy'"
  end
  def deploy_stage(stage)
    (stage == :release) ? "production" : stage
  end

end
