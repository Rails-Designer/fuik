# frozen_string_literal: true

require "test_helper"

module Fuik
  class HighlightHelperTest < ActionView::TestCase
    include Fuik::HighlightHelper

    test "generates integer indices in paths for nested arrays" do
      json = JSON.generate({ users: [{ id: 1 }, { id: 2 }] })
      output = highlighted(json)

      assert_includes output, "data-path='[\"users\"][0][\"id\"]'"
      assert_includes output, "data-path='[\"users\"][1][\"id\"]'"
    end

    test "generates string indices for hash access in data-path" do
      json = JSON.generate({ user: { name: "John" } })
      output = highlighted(json)

      assert_includes output, "data-path='[\"user\"]'"
      assert_includes output, "data-path='[\"user\"][\"name\"]'"
    end

    test "generates correct paths for nested arrays and hashes" do
      json = JSON.generate({ items: [{ name: "First" }, { name: "Second" }] })
      output = highlighted(json)

      assert_includes output, "data-path='[\"items\"][0][\"name\"]'"
      assert_includes output, "data-path='[\"items\"][1][\"name\"]'"
    end
  end
end
