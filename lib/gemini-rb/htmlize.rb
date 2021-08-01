require 'gemini-rb/parser'
require 'gemini-rb/helpers'

module Gemini
  # include Parser
  # include Helpers

  module HTML

    extend self

    def htmlize filen
      buf = <<HEADER
<html>
  <body>
HEADER
      gmi = Gemini::Parser.parse_markers(File.read("../test/data/test01.gmi",encoding: "UTF-8"))
      buf = gmi.map { |gemini|
        type = gemini[:type]
        case type
        when :header
          level = gemini[:level]
          content = gemini[:content]
          "<H#{level}>#{content}</H#{level}>\n"
        when :text
          "<p>#{gemini[:content].join("\n")}</p>"
        when :list
          "* #{gemini[:content]}<br />"
        when :verbatim
          "<pre>#{gemini[:content].join("\n")}</pre>"
        when :quote
          "#{gemini[:content]}<br />\n"
        when :uri
          text = gemini[:text]
          text = gemini[:link] if not text
          "<a href=\"#{gemini[:link]}\">#{text}</a>"
        else
          gemini.to_s
        end

      }.join("\n")
      buf += <<FOOTER
  </body>
</html>
FOOTER
      buf
    end
  end
end
