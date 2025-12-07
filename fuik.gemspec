# frozen_string_literal: true

require_relative "lib/fuik/version"

Gem::Specification.new do |spec|
  spec.name = "fuik"
  spec.version = Fuik::VERSION
  spec.authors = ["Rails Designer"]
  spec.email = ["devs@railsdesigner.com"]

  spec.summary = "A fish trap for webhooks"
  spec.description = "Fuik (Dutch for fish trap) is a Rails engine that catches and stores webhooks from any provider. View all events in the admin interface, then create event classes to add your business logic."
  spec.homepage = "https://railsdesigner.com/fuik/"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Rails-Designer/fuik/"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.0"
end
