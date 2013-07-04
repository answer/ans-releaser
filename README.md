ans-releaser
============

リリースのためのタスクを提供する

(ほぼ bundler のコード)

インストール
------------

	gem "ans-releaser"

グループは :development でよい

Rakefile や、 lib/tasks/release.rake 等に追加

### ファイルの追加等

	curl -L https://raw.github.com/answer/ans-releaser/master/install.sh | bash

gem のリリース
--------------

### プライベートホストへの gem のリリース ###

	# プライベートホストに push する場合
	require "ans-releaser"
	class GemReleaseTask
	  include Ans::Releaser::GemTask

	  def gem_host
	    "gem.host.domain" # gem を push するホスト名
	  end
	  def gem_root
	    "/path/to/gems/dir" # generate_index を走らせるディレクトリ(この下に gems ディレクトリがある)
	  end
	end

	GemReleaseTask.new.build_release_tasks

### rubygems への gem のリリース ###

	# rubygems に push する場合
	require "ans-releaser"
	class GemReleaseTask
	  include Ans::Releaser::GemTask

	  def is_rubygem
	    true
	  end
	end

	GemReleaseTask.new.build_release_tasks

以下のタスクが使用可能

	$ rake release

アプリケーションのリリース
--------------------------

	begin
	  require "ans-releaser"
	  class ApplicationReleaseTask
	    include Ans::Releaser::ApplicationTask

	    def application
	      MyApp
	    end

	    def depends_on
	      [:"assets:precompile"] # asset pipeline
	    end
	  end

	  ApplicationReleaseTask.new.build_release_tasks

	rescue NameError => ignore_unload_gem_error
	  # releaser は deployment グループでインストールするので、本番環境では存在しない
	end

以下のタスクが使用可能

	$ rake release
	$ rake staging

config/initializer/version.rb に以下の内容を保存

	module MyApp
	  VERSION = "0.0.0"
	end

MyApp はアプリケーションモジュールの名前を指定する


設定
----

オーバーライド可能なメソッドとデフォルト

	require "ans-releaser"
	class GemReleaseTask
	  include Ans::Releaser::GemTask

	  def editor
	    nil
	  end

	  def is_rubygem
	    false # rubygem に push するなら true
	  end
	  def gem_host
	    "gem.host.domain" # gem を push するホスト名
	  end
	  def gem_root
	    "/path/to/gems/dir" # generate_index を走らせるディレクトリ(この下に gems ディレクトリがある)
	  end
	  def remote_rvm_path
	    "/usr/local/rvm" # リモートホストの rvm_path
	  end
	  def remote_ruby_version
	    "1.9.2" # generate_index を走らせる rvm のバージョン
	  end

	  def depends_on
	    [] # バージョンファイルを変更する前に実行するタスク
	  end
	end

	require "ans-releaser"
	class ApplicationReleaseTask
	  include Ans::Releaser::ApplicationTask

	  def editor
	    nil
	  end

	  def application
	    MyApp
	  end

	  def depends_on
	    [] # バージョンファイルを変更する前に実行するタスク
	  end
	end

	ReleaseTask.new.build_release_tasks


概要
----

1. バージョンが書いてあるファイルを編集後、 commit
2. バージョンを読み込んでタグを作成
3. git pull, git push
4. リリース

リリースの作業は、

* GemTask の場合、 gem サーバーに push
* ApplicationTask の場合、 `RELEASE_TAG={タグ} cap {production|staging} deploy` コマンドを発行

bundler 内から呼び出すので、 capistrano は Gemfile に含まれる必要がある

editor を指定しない場合、 `VERSION="..."` の部分を検出し、自動でマイナーバージョンを上げる

