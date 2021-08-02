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
    # other lines are typed. That is all it should do!
    #
    # Resulting in
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
    # Note that I am taking some liberties here. Most importantly:
    # blank lines are counted as one and ignored by default. Also, in
    # general, the regexes assume the input is correct.
    #
    # Futher transformations should happen in other methods
    def parse_blocks(buf, include_blank_lines = false)
      # The idea is simple: collect lines and store in 'content'
      # buffer. when the type :header, :list, :quote, :uri, :verbatim,
      # :text changes push content on the 'stack'.

      def get_type(l)
        # Gemini, usefully, allows you to recognise a type at the
        # start of a string
        case l
        when ""
          :blank
        when /^#/
          :header
        when /^\*/
          :list
        when /^\>/
          :quote
        when /^\=>/
          :uri
        when /^```/
          :verbatim
        else
          :text
        end
      end

      list = []

      push = lambda { |h, type|
        if include_blank_lines
          list.push(h) if h != {} and type != nil
        else
          list.push(h) if h != {} and type != nil and type != :blank # push on the stack
        end
      }

      lines = buf.split("\n")
      h = {}
      in_block = nil
      lines.each do |line|
        l = line # should not .strip
        newtype = get_type(l) # the type of the new line
        type = h[:type] # the running type
        # pp h
        # p [:in_block,in_block,:newtype,newtype]
        if in_block == :verbatim # verbatim can contain empty lines, so it is treated different
          if newtype == :verbatim # found end of verbatim section
            in_block = nil # next block
          else
            h[:content].push l # add content and move on
            next
          end
        elsif type == :uri and newtype == :uri
          # do not put URIs in one content block
          in_block = nil
          list.push(h)
          type = nil # make sure we load the next URI
        elsif in_block # all other blocks
          if newtype != type
            in_block = nil # next block
          else
            h[:content].push l # add content and move on
            next
          end
        end
        # ---- If the type changes push the last one on the stack and
        #      initialize a new one
        if type != newtype
          push.call(h,type)
          in_block = newtype
          if newtype == :verbatim
            h = { type: newtype, content: [] }
          else
            h = { type: newtype, content: [l] }
          end
        end
      end
      push.call(h,h[:type]) # final push
      list
    end

    # Slightly more high level parser compared to parse_blocks.
    def parse_markers(buf, include_blank_lines = false)
      strip_markers(parse_blocks(buf,include_blank_lines))
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
