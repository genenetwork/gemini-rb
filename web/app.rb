$: << "../lib"

require 'sinatra'
require 'gemini-rb/htmlize'
require 'yaml'
require 'ostruct'

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

    def self.make_page(o,edit=nil)
      htmlize(o,edit)
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

# http://localhost:4567/test/data/test01.gmi
get '/test/*' do
  o = OpenStruct.new(params)
  o.site = ""
  o.skin = ""
  o.relpath = ".."+request.path_info
  o.fullpath = o.relpath
  Gemini::HTML::make_page(o)
end

# We resolve
#
#   HOST/site/skin/path

def site_skin_paths(params)
  o = OpenStruct.new(params)
  o.relpath=request.path_info.sub(/^\/gemini\/#{o.site}\/#{o.skin}\//,"")
  o.fullpath = ROOT+"/"+o.site+"/"+o.relpath
  o
end

get '/skin/:site/:skin/*' do
  site = params[:site]
  skin = params[:skin]
  spath=request.path_info.sub(/^\/skin\/#{site}/,"")
  path=ROOT+"/"+site+"/skin"+spath
  send_file(path)
end

# Temporary redirect (because we used the reversed skin/site initially)
get '/gemini/blog/pubseq/*' do
  site = params[:site]
  skin = params[:skin]
  relpath=request.path_info.sub(/^\/gemini\/blog\/pubseq\//,"")
  redirect "/gemini/pubseq/blog/"+relpath
end

# Temporary redirect (because we used the reversed skin/site initially)
get '/gemini/genenetwork/gn-gemtext-threads/*' do
  site = params[:site]
  skin = params[:skin]
  relpath=request.path_info.sub(/^\/gemini\/genenetwork\/gn-gemtext-threads\//,"")
  redirect "/gemini/gn-gemtext-threads/genenetwork/"+relpath
end

get '/gemini/:site/:skin/static/*' do
  site = params[:site]
  skin = params[:skin]
  relpath = request.path_info.sub(/^\/gemini\/#{site}\/#{skin}\//,"")
  fullpath=ROOT+"/"+site+"/"+relpath
  send_file(fullpath)
end

get '/gemini/:site/:skin/*' do
  o = site_skin_paths(params)
  Gemini::HTML::make_page(o,Gemini::HTML::gt_settings(o.site)["git-edit-prefix"])
end
