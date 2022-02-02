$: << "../lib"

require 'sinatra'
require 'gemini-rb/htmlize'
require 'yaml'

ROOT = "/home/wrk/services/gemini"
set :root, "/home/wrk/services/gemini" # hard coded for now
GEMTEXT = ROOT+"/gn-gemtext-threads"
YAMLFN = GEMTEXT+"/settings.yaml"
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

    def self.make_page(page,repo=nil,skin=nil,edit=nil)
      htmlize(page,repo,skin,edit)
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
  PATH=ROOT+"/gn-gemtext-threads"+request.path_info
  send_file(PATH)
end

get '/gemini/:skin/:repo/*' do
  skin = params[:skin]
  repo = params[:repo]
  relpath=request.path_info.sub(/^\/gemini\/#{skin}\/#{repo}\//,"")
  Gemini::HTML::make_page(relpath, repo, skin, GT_SETTINGS["git-edit-prefix"])
end
