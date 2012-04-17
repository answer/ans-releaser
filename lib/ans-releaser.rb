require "ans-releaser/version"

module Ans
  module Releaser
    autoload :GemTask, "ans-releaser/gem_task"
    autoload :ApplicationTask, "ans-releaser/application_task"
  end
end
