# frozen_string_literal: true

module Fuik
  module HighlightHelper
    def highlighted(json)
      annotate(JSON.parse(json), [], 0).html_safe
    end

    private

    def annotate(object, current_path, depth)
      case object
      when Hash
        hashed(object, current_path:, depth:)
      when Array
        arrayed(object, current_path:, depth:)
      when String
        %(<span class="json-string">"#{object}"</span>)
      when Numeric
        %(<span class="json-number">#{object}</span>)
      when TrueClass, FalseClass
        %(<span class="json-boolean">#{object}</span>)
      when NilClass
        '<span class="json-null">null</span>'
      end
    end

    def hashed(object, current_path:, depth:)
      indent = "  " * depth
      next_indent = "  " * (depth + 1)

      object.each_with_index.map do |(key, value), index|
        key_path = current_path + [key]
        path_string = key_path.map { it.is_a?(String) ? "[\"#{it}\"]" : "[#{it}]" }.join

        comma = (index == object.size - 1) ? "" : '<span class="json-punctuation">,</span>'

        "#{next_indent}#{%(<span class="json-key" data-path='#{path_string}'>"#{key}"</span>)}<span class=\"json-punctuation\">:</span> #{annotate(value, key_path, depth + 1)}#{comma}"
      end.tap do |lines|
        lines.unshift('<span class="json-punctuation">{</span>')

        lines.push("#{indent}<span class=\"json-punctuation\">}</span>")
      end.join("\n")
    end

    def arrayed(object, current_path:, depth:)
      indent = "  " * depth
      next_indent = "  " * (depth + 1)

      object.each_with_index.map do |value, index|
        comma = (index == object.size - 1) ? "" : '<span class="json-punctuation">,</span>'

        "#{next_indent}#{annotate(value, current_path + [index], depth + 1)}#{comma}"
      end.tap do |lines|
        lines.unshift('<span class="json-punctuation">[</span>')

        lines.push("#{indent}<span class=\"json-punctuation\">]</span>")
      end.join("\n")
    end
  end
end
