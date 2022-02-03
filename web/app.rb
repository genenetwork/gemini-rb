$: << "../lib"

require 'sinatra'
require 'gemini-rb/htmlize'
require 'yaml'

ROOT = "/home/wrk/services/gemini" # pick up from ENV
set :root, ROOT # hard coded for now

module Gemini
  module HTML

    def self.root()
      ROOT
    end

    def self.gt_settings site
      fn = ROOT+"/"+site+"/settings.yaml"
      if File.exist?(fn)
        YAML.load(File.read(fn))
      else
        {}
      end
    end

    def self.make_page(site,page,skin="",edit=nil)
      htmlize(site,page,skin,edit)
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
  gt_settings.to_s
end

get '/test/*.png' do
  path = ".."+request.path_info
  send_file(path)
end

get '/test/*' do
  path = ".."+request.path_info
  Gemini::HTML::make_page("",path)
end

get '/skin/:site/:skin/*' do
  site = params[:site]
  skin = params[:skin]
  spath=request.path_info.sub(/^\/skin\/#{site}/,"")
  path=ROOT+"/"+site+"/skin"+spath
  send_file(path)
end

get '/gemini/:skin/:site/static/*' do
  skin = params[:skin]
  site = params[:site]
  relpath=request.path_info.sub(/^\/gemini\/#{skin}\//,"")
  send_file(ROOT+"/"+relpath)
end

get '/gemini/:skin/:site/*' do
  skin = params[:skin]
  site = params[:site]
  relpath=request.path_info.sub(/^\/gemini\/#{skin}\//,"")
  Gemini::HTML::make_page(site,relpath, skin, Gemini::HTML::gt_settings(site)["git-edit-prefix"])
end
