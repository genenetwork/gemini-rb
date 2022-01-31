$: << "../lib"

require 'sinatra'
require 'gemini-rb/htmlize'

ROOT = "/home/wrk/services/gemini"
set :root, "/home/wrk/services/gemini" # hard coded for now
GEMTEXT = ROOT+"/gn-gemtext-threads"

module Gemini
  module HTML

    def self.root()
      ROOT
    end

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

get '/skin/*' do
  PATH=ROOT+"/gn-gemtext-threads"+request.path_info
  send_file(PATH)
end

get '/gemini/*' do
  PATH=request.path_info.sub(/^\/gemini\//,"")
  Gemini::HTML::make_page(settings.root+"/"+PATH)
end
