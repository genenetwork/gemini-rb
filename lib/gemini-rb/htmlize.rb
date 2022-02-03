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

    def htmlize site, filen, skin="", edit_prefix=nil
      path =
        if File.exist?(filen)
          filen
        else
          path   = root + "/" + filen
        end
      spath   = root + "/" + site + "/skin/" + skin
      head   = read_file_if_exists(spath,"header.html")
      banner   = read_file_if_exists(spath,"banner.html")
      footer   = read_file_if_exists(spath,"footer.html")
      edit_button =
        if edit_prefix
          efn = edit_prefix+"/"+filen.sub(/#{site}\//,"")
          <<BUTTON
      <div class="edit">
        <div class="github-btn-container">
          <div class="github-btn">
            <a href="#{efn}">
            edit page
              <!-- <img src="/static/images/edit.png"> -->
            </a>
          </div>
        </div>
      </div>
BUTTON
        else
          ""
        end

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
      #{edit_button}

HEADER
      if !File.exist?(path)
        return "ERROR: file #{filen} does not exist on this server"
      end
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
          if url =~ /\.(png|jpg|jpeg)$/i
            %{<img src="#{url}" />}
          else
            # fill out proxy if it is a gemini link
            proxy = "https://portal.mozz.us/gemini/"
            if url =~ /^gemini:\/\//
              url = url.sub(/^gemini:\/\//,proxy)
            end
            "=> <a href=\"#{url}\">#{text}</a><br />"
            # url
          end
        else
          gemini.to_s
        end

      }.join("\n")
      buf += <<FOOTER
      #{edit_button}
    </div> <!-- content -->
  #{footer}
  </body>
</html>
FOOTER
      gemini = gt_settings(site)["gemini"]
      if gemini
        buf += <<GEMINI
        <div class="footer">
          <div class="gemini">
            Read with a
            <a href="https://en.wikipedia.org/wiki/Gemini_(protocol)">
             gemini
            </a> reader:
            #{gemini + "/" + filen}
          </div>
        </div>
GEMINI
      end
      buf
    end
  end
end
