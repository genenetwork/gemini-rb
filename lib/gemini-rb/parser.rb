# Main parser for the gemini format. The parser splits the input buffer into lines
# and returns a list of items with keywords. The basics are:
#
# [
#  { type: :header, level: 1, content: "Gemtext cheatsheet" },
#  { type: :text, content: [ "Here's the basics of how text works in Gemtext:"] },
#  { type: :list, content: "item" },
#  { type: :quote, content: "item" },
#  { type: :verbatim, content: [ "line1", "line2"] },
#  { type: :uri, link: "gemini://xxx.yyy", content: "This is a link" }
# ]
#
# New lines are embedded in :text and :verbatim as "". Between types they are assumed.
#
# See also the included test module

module Gemini

  module Parser

    extend self

    # Very simple block splitter. Makes sure text and verbatim blocks are together and
    # other lines are typed. That is all it should do! Resulting in
    # [{:type=>:header, :content=>["# Gemtext cheatsheet"]},
    # {:type=>:text, :content=>["Here's the basics of how text works in Gemtext:"]},
    # {:type=>:list,
    # :content=>
    # ["* Long lines get wrapped by the client to fit the screen",
    #  "* Short lines *don't* get joined together",
    #  "* Write paragraphs as single long lines",
    #  "* Blank lines are rendered verbatim"]},
    # {:type=>:header, :content=>["## Headings"]},
    # {:type=>:text, :content=>["You get three levels of heading:"]},
    # {:type=>:verbatim,
    #  :content=>["# Heading", "", "## Sub-heading", "", "### Sub-subheading"]},
    # ... ]
    #
    # Futher transformations should happen in other methods
    def parse_blocks(buf)
      lines = buf.split("\n")
      list = []
      h = {}
      inblock = false
      inverbatim = false
      lines.each do |line|
        l = line.strip
        type = h[:type]
        content = h[:content]
        if inverbatim
          if l =~ /^```/ # verbatim can contain empty lines, so it is different
            list.push(h)
            inblock = false
            inverbatim = false
          else
            h[:content].push l
          end
        elsif inblock
          if l == ""
            list.push(h)
            inblock = false
          else
            h[:content].push l
          end
        else
          if l == ""
            next
          elsif l =~ /^#/
            h = { type: :header, content: [l] }
          elsif l =~ /^\*/
            h = { type: :list, content: [l] }
            inblock = true
          elsif l =~ /^\>/
            h = { type: :quote, content: [l] }
            inblock = true
          elsif l =~ /^\=>/
            h = { type: :uri, content: [l] }
          elsif l =~ /^```/
            h = { type: :verbatim, content: [] }
            inverbatim = true
            inblock = true
          else
            h = { type: :text, content: [l] }
            inblock = true
          end
          list.push(h) if !inblock # push the singletons
        end
      end
      list
    end

    # Slightly more high level parser compared to parse_blocks.
    def parse_markers(buf)
      strip_markers(parse_blocks(buf))
    end

    # ---- Below methods work on GMI type

    # Helper for stripping markers. Note that because of the blocks it
    # now is a simple map
    def strip_markers(gmi)
      gmi.map { | h |
        # h in { type: type, content: content } # Ruby 3 only
        type = h[:type]
        content = h[:content]
        text = content[0]
        case type
        when :header
          m = /^(#+)(\s*)(.*)/.match(text)
          level = m[1].count("#")
          { type: type, level: level, content: [m[3]] }
        when :list
          { type: type, content: content.map { |t| t.sub(/^\*\s*/,"") }}
        when :quote
          { type: type, content: content.map { |t| t.sub(/^\>\s?/,"") }}
        when :uri
          a = text.sub(/^=>\s*/,"").split(" ",2)
          link = a[0]
          text = a[1]
          { type: type, link: link, text: text }
        else
          h
        end
      }
    end


  end

end
