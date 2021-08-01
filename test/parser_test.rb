
require_relative '../lib/gemini-rb/parser'
require_relative '../lib/gemini-rb/helpers'
require 'minitest/autorun'
require 'pp'


class ParserTest < MiniTest::Test

  include Gemini::Parser
  include Gemini::Helpers

  def test_parse_blocks
    # Simple block parser with no content transformations
    gmi = parse_blocks(File.read("data/test01.gmi", encoding: "UTF-8"))
    assert_equal({type: :header, content: "# Gemtext cheatsheet"}, gmi[0])
    assert_equal({:type=>:text, :content=>["Here's the basics of how text works in Gemtext:"]}, gmi[1])
    assert_equal({:type=>:list, :content=>"* Long lines get wrapped by the client to fit the screen"}, gmi[2])
    assert_equal({:type=>:verbatim, :content=>["* Mercury", "* Gemini", "* Apollo"]}, gmi[10])
    assert_equal({:type=>:uri, :content=>"=> gemini://gemini.circumlunar.space/docs/cheatsheet.gmi"}, gmi.last)
  end

  def test_strip_markers
    # First transform sets header levels, splits URI text, and cleans up markers in content
    gmi = strip_markers(parse_blocks(File.read("data/test01.gmi", encoding: "UTF-8")))
    assert_equal({type: :header, level: 1, content: "Gemtext cheatsheet"}, gmi[0])
    assert_equal({type: :text, content: ["Here's the basics of how text works in Gemtext:"]}, gmi[1])
    assert_equal({type: :list, :content=>"Long lines get wrapped by the client to fit the screen"}, gmi[2])
    assert_equal({type: :verbatim, content: ["* Mercury", "* Gemini", "* Apollo"]}, gmi[10])
    assert_equal({type: :uri, link: "gemini://gemini.circumlunar.space/docs/cheatsheet.gmi", text: nil}, gmi.last)
  end

  def test_uris
    gmi = strip_markers(parse_blocks(File.read("data/test_uris.gmi", encoding: "UTF-8")))
    uris = [
      {type: :uri, link: "gemini://gemini.circumlunar.space/docs/cheatsheet.gmi", text: nil},
      {type: :uri, link: "gemini://gemini.circumlunar.space/docs/cheatsheet.gmi", text: "Cheat sheet"},
    ]
    pp gmi
    gmi.each_with_index do | gemini,i |
      assert_equal(uris[i], uri_info(gemini), gmi[i])
    end
  end

end
