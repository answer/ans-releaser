# -*- coding: utf-8 -*-

module Ans::Releaser::ReleaseHelper
  include Rake::DSL if defined? Rake::DSL

  def build_release_tasks
    task :up_version do
      sh "#{editor} #{version_file}"
      git_commit version_file, "up version"
      after_up_version
    end

    depends_on = depends_on || []
    depends_on.unshift :up_version

    stages.each do |stage|
      desc "リリース to #{stage}"
      task stage do
        perform_release stage
      end
      task stage => depends_on
    end
  end

  def after_up_version
    # バージョンを上げた後にやる作業
  end

  def editor
    "vi"
  end

  def depends_on
    []
  end

  def guard_clean
    clean? or raise("コミットされていない変更があります。 git status を clean にしてください")
  end

  def clean?
    sh_with_code("git diff --exit-code")[1] == 0
  end

  def tag_version(stage)
    sh "git tag -a -m \"Version #{version} on #{stage}\" #{version_tag stage}"
    yield if block_given?
  rescue
    sh_with_code "git tag -d #{version_tag stage}"
    raise
  end

  def git_commit(file,message)
    cmd = "git add #{file} && git commit -m '#{message}'"
    out, code = sh_with_code(cmd)
    raise "git commit できませんでした。 `#{cmd}' output:\n\n#{out}\n" unless code == 0
  end

  def git_pull
    cmd = "git pull"
    out, code = sh_with_code(cmd)
    raise "git pull できませんでした。 `#{cmd}' output:\n\n#{out}\n" unless code == 0
  end

  def git_push
    perform_git_push
    perform_git_push ' --tags'
  end

  def perform_git_push(options='')
    cmd = "git push #{options}"
    out, code = sh_with_code(cmd)
    raise "git push できませんでした。 `#{cmd}' output:\n\n#{out}\n" unless code == 0
  end

  def guard_already_tagged(stage)
    if `git tag 2>&1`.split(/\n/).include?(version_tag stage)
      raise("このタグは既に存在します。 config/initializers/version.rb のバージョンを上げてください")
    end
  end

  def version_tag(stage)
    "v#{version}-#{stage}"
  end

  def sh_with_code(cmd, &block)
    puts cmd
    cmd << " 2>&1"
    outbuf = `#{cmd}`
    if $? == 0
      block.call(outbuf) if block
    end
    [outbuf, $?]
  end
end
