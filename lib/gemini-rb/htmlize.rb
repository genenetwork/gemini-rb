require 'gemini-rb/parser'
require 'gemini-rb/helpers'

module Gemini

  module HTML

    extend self

    def htmlize filen
      buf = <<HEADER
<html>
  <body>
HEADER
      gmi = Gemini::Parser.parse_markers(File.read(filen,encoding: "UTF-8"))
      buf = gmi.map { |gemini|
        type = gemini[:type]
        case type
        when :header
          level = gemini[:level]
          content = gemini[:content]
          "<H#{level}>#{content.join(" ")}</H#{level}>\n"
        when :text
          "<p>#{gemini[:content].join("\n")}</p>"
        when :list
          "<ul>"+
          gemini[:content].map { |item|
            "<li> #{item}</li>"
          }.join("\n")+"\n</ul>\n"
        when :verbatim
          "<pre>#{gemini[:content].join("\n")}</pre>"
        when :quote
          "<blockquote>"+
          "#{gemini[:content].join("<br />\n")}</blockquote>\n"
        when :uri
          text =
            if gemini[:text]
              gemini[:text]
            else
              gemini[:link]
            end
          url = gemini[:link]
          proxy = "https://portal.mozz.us/gemini/"
          if url =~ /^gemini:\/\//
            url = url.sub(/^gemini:\/\//,proxy)
          end
          "=> <a href=\"#{url}\">#{text}</a><br />"
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
