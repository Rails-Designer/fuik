# frozen_string_literal: true

module Fuik
  module HighlightHelper
    def highlighted(json_string)
      highlighted = json_string
        .gsub(/("[\w\s\-_]+")(\s*:)/, '<span class="json-key">\1</span><span class="json-punctuation">\2</span>')
        .gsub(/:\s*(".*?")/, ': <span class="json-string">\1</span>')
        .gsub(/:\s*(\d+\.?\d*)/, ': <span class="json-number">\1</span>')
        .gsub(/:\s*(true|false)/, ': <span class="json-boolean">\1</span>')
        .gsub(/:\s*(null)/, ': <span class="json-null">\1</span>')
        .gsub(/([{}\[\],])/, '<span class="json-punctuation">\1</span>')

      highlighted.html_safe
    end
  end
end
