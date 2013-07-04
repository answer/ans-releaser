bundle=bundle.sh
release=release.sh
rakefile=Rakefile
gemfile=Gemfile

echo '#!/bin/sh' > $bundle
echo 'bundle install --path=.bundle/bundle' >> $bundle
chmod a+x $bundle

echo '#!/bin/sh' > $release
echo 'bundle exec rake release' >> $release
chmod a+x $release

cat << RAKEFILE > $rakefile
require "ans-releaser"
class GemReleaseTask
  include Ans::Releaser::GemTask

  def gem_host
    "gem.ans-web.co.jp"
  end
  def gem_root
    "/var/www/gem/public"
  end
end

GemReleaseTask.new.build_release_tasks
RAKEFILE

cat << GEMFILE > $gemfile
source 'https://rubygems.org'
source 'http://gem.ans-web.co.jp/public'

gemspec

gem "ans-releaser"
GEMFILE
