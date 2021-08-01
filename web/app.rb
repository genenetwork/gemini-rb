$: << "../lib"

require 'sinatra'
require 'gemini-rb/htmlize'

module Gemini
  module HTML

    def self.make_page
      htmlize("../test/data/test01.gmi")
    end
  end
end

get '/' do
  'Hello gemini viewer!'
end

get '/test' do
  Gemini::HTML::make_page
end
