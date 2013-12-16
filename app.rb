require 'bundler/setup'
Bundler.require(:default)
require_relative 'classes'

get '/' do
@artist = ""
if params[:artist]
@artist = artist(params[:artist])
end

erb :index
end

post '/' do
@artist = ""
if params[:artist]
@artist = artist(params[:artist])
end

erb :index
end