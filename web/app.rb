$: << "../lib"

require 'sinatra'
require 'gemini-rb/htmlize'
require 'yaml'

ROOT = "/home/wrk/services/gemini/gn-gemtext-threads" # pick up from ENV
set :root, ROOT # hard coded for now
YAMLFN = ROOT+"/settings.yaml"
GT_SETTINGS =
  if File.exist?(YAMLFN)
    YAML.load(File.read(YAMLFN))
  else
    {}
  end

module Gemini
  module HTML

    def self.root()
      ROOT
    end

    def self.make_page(page,skin=nil,edit=nil)
      htmlize(page,skin,edit)
    end
  end
end

get '/' do
  'Hello gemini viewer!'
end

get '/root' do
  settings.root
end

get '/settings' do
  GT_SETTINGS.to_s
end

get '/test' do
  Gemini::HTML::make_page("../test/data/test01.gmi")
end

get '/skin/*' do
  PATH=ROOT+request.path_info
  send_file(PATH)
end

get '/gemini/:skin/:repo/*' do
  skin = params[:skin]
  repo = params[:repo]
  relpath=request.path_info.sub(/^\/gemini\/#{skin}\/#{repo}\//,"")
  Gemini::HTML::make_page(relpath, skin, GT_SETTINGS["git-edit-prefix"])
end
