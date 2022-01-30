$: << "../lib"

require 'sinatra'
require 'gemini-rb/htmlize'

set :root, "/home/wrk/services/gemini"

module Gemini
  module HTML

    def self.make_page(page)
      htmlize(page)
    end
  end
end

get '/' do
  'Hello gemini viewer!'
end

get '/root' do
  settings.root
end

get '/test' do
  Gemini::HTML::make_page("../test/data/test01.gmi")
end

get '/gemini/*' do
  PATH=request.path_info.sub(/^\/gemini\//,"")
  Gemini::HTML::make_page(settings.root+"/"+PATH)
end
