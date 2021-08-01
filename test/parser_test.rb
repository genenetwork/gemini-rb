
require_relative '../lib/gemini-rb/parser'
require 'minitest/autorun'
require 'pp'


class ParserTest < MiniTest::Test

  include Gemini

  def test_parse_blocks
    gmi = parse_blocks(File.read("data/test01.gmi", encoding: "UTF-8"))
    pp gmi
    assert_equal ( {type: :header, content: "# Gemtext cheatsheet"}, gmi[0])
  end

end
