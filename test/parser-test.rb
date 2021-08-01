
require_relative '../lib/gemini-rb/parser'
require 'minitest/autorun'


class ParserTest < MiniTest::Test

  include Gemini

  def test_normal
    gmi = parse(File.read("data/test.gmi")
    # assert_equal 24, factorial(4),"4! should be 24"
  end

end
