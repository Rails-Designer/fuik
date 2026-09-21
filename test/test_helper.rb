# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"

ActiveRecord::Migrator.migrations_paths = [ File.expand_path("../test/dummy/db/migrate", __dir__) ]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)

require "rails/test_help"

ActiveJob::Base.queue_adapter = :inline

module NonLocalEnvHelper
  def with_non_local_env
    Rails.singleton_class.alias_method :__original_env, :env
    Rails.singleton_class.define_method(:env) { ActiveSupport::StringInquirer.new("production") }

    yield
  ensure
    Rails.singleton_class.remove_method(:env)
    Rails.singleton_class.alias_method :env, :__original_env
    Rails.singleton_class.remove_method(:__original_env)
  end
end

ActiveSupport::TestCase.include NonLocalEnvHelper
