# -*- coding: utf-8 -*-

module Ans::Releaser::GemTask
  include Rake::DSL if defined? Rake::DSL
  include Ans::Releaser::ReleaseHelper

  def stages
    [:release]
  end

  def version_file
    Dir["lib/*/version.rb"].first
  end

  def is_rubygem
    false
  end
  def gem_host
    "gem.host.domain"
  end
  def gem_root
    "/path/to/gem/root"
  end
  def remote_rvm_path
    "/usr/local/rvm"
  end
  def remote_ruby_version
    "1.9.2"
  end

  def perform_release(stage)
    git_pull
    guard_clean
    guard_already_tagged stage
    gem_path = build_gem
    tag_version(stage) {
      git_push
      if is_rubygem
        rubygem_push gem_path
      else
        private_gem_push gem_path
      end
    }
  end

  def base
    @base ||= Dir.pwd
  end
  def spec_path
    @spec_path ||= Dir[File.join(base, "{,*}.gemspec")].first
  end

  def version
    Bundler.clear_gemspec_cache
    gemspec.version
  end
  def name
    gemspec.name
  end
  def gemspec
    @gemspec = Bundler.load_gemspec(spec_path)
  end

  def build_gem
    file_name = nil
    sh("gem build -V '#{spec_path}'") { |out, code|
      file_name = File.basename(built_gem_path)
      FileUtils.mkdir_p(File.join(base, 'pkg'))
      FileUtils.mv(built_gem_path, 'pkg')
      puts "#{name} #{version} built to pkg/#{file_name}"
    }
    File.join(base, 'pkg', file_name)
  end
  def built_gem_path
    Dir[File.join(base, "#{name}-*.gem")].sort_by{|f| File.mtime(f)}.last
  end

  def rubygem_push(path)
    if Pathname.new("~/.gem/credentials").expand_path.exist?
      sh("gem push '#{path}'")
      puts "Pushed #{name} #{version} to rubygems.org"
    else
      raise "Your rubygems.org credentials aren't set. Run `gem push` to set them."
    end
  end
  def private_gem_push(path)
    sh "scp #{path} #{gem_host}:#{gem_root}/gems"
    sh %Q{ssh #{gem_host} "rvm_path=#{remote_rvm_path} #{remote_rvm_path}/bin/rvm-shell '#{remote_ruby_version}' -c 'cd #{gem_root} && gem generate_index'"}
    puts "Pushed #{name} #{version} to #{gem_host}"
  end
end
