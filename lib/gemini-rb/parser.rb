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

  # Very simple block splitter. Makes sure text and verbatim blocks are together and
  # other lines are typed. That is all it should do! Resulting in
  # [{:type=>:header, :content=>"# Gemtext cheatsheet"},
  #  {:type=>:text, :content=>["Here's the basics of how text works in Gemtext:"]},
  #   {:type=>:list, :content=>"* Long lines get wrapped by the client to fit the screen"},
  #   {:type=>:list, :content=>"* Short lines *don't* get joined together"},
  #   {:type=>:list, :content=>"* Write paragraphs as single long lines"},
  #   {:type=>:list, :content=>"* Blank lines are rendered verbatim"},
  # {:type=>:header, :content=>"## Headings"},
  #  {:type=>:text, :content=>["You get three levels of heading:"]},
  #  {:type=>:verbatim, :content=>["# Heading", "", "## Sub-heading", "", "### Sub-subheading"]}, ... ]
  #
  # Futher transformations should happen in other methods
  def parse_blocks(buf)
    lines = buf.split("\n")
    list = []
    h = {}
    inblock = false
    lines.each do |line|
      l = line.strip
      # First decide if we have a new type
      if inblock
        if h[:type] == :verbatim
          if l =~ /^```/
            inblock = false
          else
            h[:content].push l
          end
        else # type == :text
          if l == ""
            inblock = false
          else
            h[:content].push l
          end
        end
      else
        if l == ""
          next
        elsif l =~ /^#/
          h = { type: :header, content: l }
        elsif l =~ /^\*/
          h = { type: :list, content: l }
        elsif l =~ /^\>/
          h = { type: :quote, content: l }
        elsif l =~ /^\=>/
          h = { type: :uri, content: l }
        elsif l =~ /^```/
          h = { type: :verbatim, content: [] }
          inblock = true
        else
          h = { type: :text, content: [ l ] }
          inblock = true
        end
      end
      if !inblock
        list.push(h)
      end
    end
    list
  end

  def transform1(gmi)
    gmi
  end
end
