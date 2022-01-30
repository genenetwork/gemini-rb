# Run as:
#
#   cd test && ruby parser_test.rb
#

require_relative '../lib/gemini-rb/parser'
require_relative '../lib/gemini-rb/helpers'
require 'minitest/autorun'
require 'pp'


class ParserTest < MiniTest::Test

  include Gemini::Parser
  include Gemini::Helpers

  def test_parse_blocks01
    # Simple block parser with no content transformations
    gmi = parse_blocks(File.read("data/test01.gmi", encoding: "UTF-8"))
    pp gmi
    assert_equal(15,gmi.size)
    assert_equal({type: :header, content: ["# Gemtext cheatsheet"]}, gmi[0])
    assert_equal({:type=>:text, :content=>["Here's the basics of how text works in Gemtext:"]}, gmi[1])
    assert_equal({:type=>:list, :content=>["* Long lines get wrapped by the client to fit the screen", "* Short lines *don't* get joined together", "* Write paragraphs as single long lines", "* Blank lines are rendered verbatim"]}, gmi[2])

    assert_equal({:type=>:verbatim, :content=>["* Mercury", "* Gemini", "* Apollo"]}, gmi[7])
    assert_equal({:type=>:uri, :content=>["=> gemini://gemini.circumlunar.space/docs/cheatsheet.gmi"]}, gmi.last)
  end

  def test_parse_blocks01_blanks
    # Simple block parser with no content transformations
    gmi = parse_blocks(File.read("data/test01.gmi", encoding: "UTF-8"),true)
    # pp gmi
    assert_equal(29,gmi.size)
    assert_equal({type: :header, content: ["# Gemtext cheatsheet"]}, gmi[0])
    assert_equal({:type=>:text, :content=>["Here's the basics of how text works in Gemtext:"]}, gmi[2])
    assert_equal({:type=>:list, :content=>["* Long lines get wrapped by the client to fit the screen", "* Short lines *don't* get joined together", "* Write paragraphs as single long lines", "* Blank lines are rendered verbatim"]}, gmi[4])

    assert_equal({:type=>:verbatim, :content=>["* Mercury", "* Gemini", "* Apollo"]}, gmi[14])
    assert_equal({:type=>:uri, :content=>["=> gemini://gemini.circumlunar.space/docs/cheatsheet.gmi"]}, gmi.last)
  end

  def test_parse_blocks02
    # Simple block parser with no content transformations
    gmi = parse_blocks(File.read("data/test02.gmi", encoding: "UTF-8"))
    # pp gmi
    assert_equal({type: :header, content: ["# Gemtext cheatsheet (test02.gmi)"]}, gmi[0])
    assert_equal({:type=>:text, :content=>["Here's the basics of how text works in Gemtext:"]}, gmi[1])
    assert_equal({:type=>:list, :content=>["* Long lines get wrapped by the client to fit the screen", "* Short lines *don't* get joined together", "* Write paragraphs as single long lines", "* Blank lines are rendered verbatim"]}, gmi[2])

    assert_equal({:type=>:verbatim, :content=>["* Mercury", "* Gemini", "* Apollo"]}, gmi[7])
    # pp gmi
    assert_equal({:type=>:uri, :content=>["=> gemini://gemini.circumlunar.space/docs/cheatsheet.gmi"]}, gmi[-2])
    assert_equal({:type=>:uri, :content=>["=> gemini://gemini.circumlunar.space/docs/cheatsheet.gmi Cheat sheet (2)"]}, gmi.last)
  end

  def test_parse_blocks01_blanks
    # Simple block parser with no content transformations
    gmi = parse_blocks(File.read("data/test03.gmi", encoding: "UTF-8"),true)
    # pp gmi
    assert_equal(6,gmi.size)
    assert_equal({:type=>:header, :content=>["# Heading"]}, gmi[0])
    assert_equal({:type=>:header, :content=>["### Sub sub heading"]}, gmi[2])
    assert_equal({type: :blank, content: ["","",""]}, gmi[4])
  end

  def test_stripped_markers02
    # First transform sets header levels, splits URI text, and cleans up markers in content
    gmi = parse_markers(File.read("data/test01.gmi", encoding: "UTF-8"))
    # pp gmi
    assert_equal(15,gmi.size)
    assert_equal({type: :header, level: 1, content: ["Gemtext cheatsheet"]}, gmi[0])
    assert_equal({type: :header, level: 2, content: ["Headings"]}, gmi[3])
    assert_equal({type: :text, content: ["Here's the basics of how text works in Gemtext:"]}, gmi[1])
    assert_equal( {:type=>:list, :content=>["Long lines get wrapped by the client to fit the screen", "Short lines *don't* get joined together", "Write paragraphs as single long lines", "Blank lines are rendered verbatim"]}, gmi[2])
    assert_equal({type: :verbatim, content: ["* Mercury", "* Gemini", "* Apollo"]}, gmi[7])
    assert_equal({:type=>:quote, :content=>["Line 1", "Line 2"]}, gmi[-4])
    assert_equal({:type=>:text, :content=>["Proxied content from"]}, gmi[-2])
    assert_equal({type: :uri, link: "gemini://gemini.circumlunar.space/docs/cheatsheet.gmi", text: nil}, gmi.last)
  end

  def test_stripped_markers03
    # First transform sets header levels, splits URI text, and cleans up markers in content
    gmi = parse_markers(File.read("data/test03.gmi", encoding: "UTF-8"),true)
    assert_equal([{:type=>:header, :level=>1, :content=>["Heading"]},
                  {:type=>:header, :level=>2, :content=>["Sub heading"]},
                  {:type=>:header, :level=>3, :content=>["Sub sub heading"]},
                  {:type=>:text, :content=>["This is text"]},
                  {:type=>:blank, :content=>["", "", ""]},
                  {:type=>:text, :content=>["and three blank lines."]}],gmi)
  end

  def test_uris
    gmi = parse_markers(File.read("data/test_uris.gmi", encoding: "UTF-8"))
    # pp gmi
    assert_equal(14,gmi.size)
    uris = [
      {:type=>:uri, :link=>"gemini://gemini.circumlunar.space/docs/cheatsheet.gmi", :text=>nil, :scheme=>"gemini"},
      {:type=>:uri, :link=>"gemini://gemini.circumlunar.space/docs/cheatsheet.gmi", :text=>"Cheat sheet", :scheme=>"gemini"},
      {:type=>:uri, :link=>"https://thebird.nl/", :text=>nil, :scheme=>"https"},
      {:type=>:uri, :link=>"https://thebird.nl/blog/work/group.html#orgb77c658", :text=>nil, :scheme=>"https"},
      {:type=>:uri, :link=>"file:///no-exist.png", :text=>nil, :scheme=>"file"},
      {:type=>:uri, :link=>"file://localhost/etc/no-exist.png", :text=>nil, :scheme=>"file"},
      {:type=>:uri, :link=>"no-exist.png", :text=>nil, :scheme=>nil},
      {:type=>:uri, :link=>"no-exist.png", :text=>"Image does not exist", :scheme=>nil},
      {:type=>:uri, :link=>"does-exist.png", :text=>nil, :scheme=>"local"},
      {:type=>:uri, :link=>"does-exist.png", :text=>"Image does exist", :scheme=>"local"},
      {:type=>:uri, :link=>"./no-exist.png", :text=>nil, :scheme=>nil},
      {:type=>:uri, :link=>"./no-exist.png", :text=>"Image does not exist", :scheme=>nil},
      {:type=>:uri, :link=>"./does-exist.png", :text=>nil, :scheme=>"local"},
      {:type=>:uri, :link=>"./does-exist.png", :text=>"Image does exist", :scheme=>"local"}
    ]
    Dir.chdir("data/") do
      gmi.each_with_index do | gemini,i |
        assert_equal(uris[i], uri_info(gemini), gmi[i])
      end
    end
  end

end
