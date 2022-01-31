require 'sinatra'
require 'gemini-rb/parser'
require 'gemini-rb/helpers'

module Gemini

  module HTML

    extend self

    def read_file_if_exists(path,fn)
      fn2 = path+"/"+fn
      if File.exist?(fn2)
        File.read(fn2, encoding: "UTF-8")
      else
        "<!-- Can not read #{fn2} -->"
      end
    end

    def htmlize filen
      skin   = "gn-gemtext-threads/skin/genenetwork" # hard coded
      path   = root + "/" + skin
      head   = read_file_if_exists(path,"header.html")
      banner   = read_file_if_exists(path,"banner.html")
      footer   = read_file_if_exists(path,"footer.html")
      buf = <<HEADER
<html>
  <head>
    #{head}
  </head>
  <body>
    <div class="banner">
    #{banner}
    </div> <!-- banner -->
    <div class="content">
HEADER
      gmi = Gemini::Parser.parse_markers(File.read(filen,encoding: "UTF-8"))
      buf += gmi.map { |gemini|
        type = gemini[:type]
        case type
        when :header
          level = gemini[:level]
          content = gemini[:content]
          "<H#{level}>#{content.join(" ")}</H#{level}>\n"
        when :text
          %{
<div class="text">
  <p>
  #{gemini[:content].join("\n")}
  </p>
</div>
}
        when :list
          "<div class=\"list\"><ul>"+
          gemini[:content].map { |item|
            "<li> #{item}</li>"
          }.join("\n")+"\n</ul></div>\n"
        when :verbatim
          %{
<div class="verbatim">
<pre>
#{gemini[:content].join("\n")}
</pre>
</div>
}
        when :quote
          %{
<div class="quote">
<blockquote>
#{gemini[:content].join("<br />\n")}
</blockquote>
</div>
}
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

    </div> <!-- content -->
  #{footer}
  </body>
</html>
FOOTER
      buf
    end
  end
end
