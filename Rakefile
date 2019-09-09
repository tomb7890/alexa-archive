require 'sinatra/base'
require './downloader.rb'
require './server.rb'

task :download do
  d = Downloader.new
  d.download 
end

task :server do
  Server.run! 
end

task :test do
  Rspec spec
end
