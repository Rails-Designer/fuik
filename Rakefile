# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test"

  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
  t.warning = true
end

require "standard/rake"

task default: %i[test standard]
