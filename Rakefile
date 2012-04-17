require "ans-releaser"

class Ans::Releaser::Task
  include Ans::Releaser::GemTask

  module ClassMethods
    def install_tasks
      new.build_release_tasks
    end
  end
  extend ClassMethods

  def after_up_version
    # バージョンを再読み込み
    eval(File.read("lib/ans-releaser/version.rb"))
  end

  def gem_host
    "gem.ans-web.co.jp"
  end
  def gem_root
    "/var/www/gem/public"
  end
end

Ans::Releaser::Task.install_tasks
