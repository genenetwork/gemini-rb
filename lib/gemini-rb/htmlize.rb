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

    def htmlize filen, skin=nil, edit_prefix=nil
      skin2   = "#{repo}/skin/#{skin}" # hard coded
      path   = root + "/" + repo + "/" + filen
      spath   = root + "/" + skin2
      head   = read_file_if_exists(spath,"header.html")
      banner   = read_file_if_exists(spath,"banner.html")
      footer   = read_file_if_exists(spath,"footer.html")
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
      <div class="edit">
        <div class="github-btn-container">
          <div class="github-btn">
            <a href="#{edit_prefix}/#{filen}">
            edit page
              <!-- <img src="/static/images/edit.png"> -->
            </a>
          </div>
        </div>
      </div>
HEADER
      gmi = Gemini::Parser.parse_markers(File.read(path,encoding: "UTF-8"))
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
          if File.exist?(url)
            %{<img src="#{url}" />}
          else
            proxy = "https://portal.mozz.us/gemini/"
            if url =~ /^gemini:\/\//
              url = url.sub(/^gemini:\/\//,proxy)
            end
            "=> <a href=\"#{url}\">#{text}</a><br />"
          end
        else
          gemini.to_s
        end

      }.join("\n")
      buf += <<FOOTER
      <div class="edit">
            <a href="#{edit_prefix}/#{filen}">
            edit page
            </a>
      </div>
    </div> <!-- content -->
  #{footer}
  </body>
</html>
FOOTER
      buf
    end
  end
end
