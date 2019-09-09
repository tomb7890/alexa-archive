require 'sinatra/base'
require 'nokogiri'
require './downloader'

#
#  AlexaClone is a Sinatra app that serves the lesson and assignment
#  pages downloaded from the Alexa website, for a given Bitmaker
#  cohort.  Use downloader.rb to download the pages.
class Server < Sinatra::Base

  set :bind, '0.0.0.0' 

  # #
  # Routes
  #

  get '/:section/:id' do
    html = retrieve_html(params[:section], params[:id])
    erb html unless html.nil?
  end

  get '/:section' do |section|
    @data = get_data(section)
    erb :section
  end

  get '/' do
    @data = get_data('lessons')
    erb :section
  end


  # #
  # Methods
  #

  def server
    start!
  end

  def id_from_filename(filename)
    basename = filename.split('/')[-1]
    basename.match(/_(\d+)__/)[1]
  end

  def title_from_filename(filename)
    html = File.open(filename, 'r').read
    ndoc = Nokogiri::HTML(html)
    ndoc.search('//h1[@class="resource-title"]').text
  end

  def get_title_for_page
    @data[0][:section].capitalize
  end

  def get_data(section)
    
    data = []
    Dir.glob(Dir.pwd + "/public/#{section}/*.*").each do |f|
      id = id_from_filename(f)
      resource_title = title_from_filename(f)
      dict = { title: resource_title, id: id, section: section }
      data << dict
    end
    data.sort_by { |hsh| hsh[:id] }
    
  end

  def fetch_filename(section, id)
    Dir.glob(Dir.pwd + "/public/#{section}/*#{id}*")[0]
  end

  def retrieve_html(section, id)
    filename = fetch_filename(section, id)
    File.open(filename, 'r').read unless filename.nil?
  end

  # #
  # Invocation
  #

  if ARGV[0] == 'download'
    s = Downloader.new
    s.download
  else
    raise "Data Directory doesn't exist. Run 'rake download to download the data."  unless File.directory?("public")
    start! if app_file == $PROGRAM_NAME
  end
end
