require 'mechanize'
require 'nokogiri'
require 'yaml'

class Downloader

  LOGIN_URL = 'https://alexa.bitmaker.co'
  URL = 'https://alexa.bitmaker.co/wdi/march-2015'

  def getconfig
    configfile = 'config/config.yml'
    YAML.load_file(configfile)
  end

  def getoption(opt)
    rc = nil
    config = getconfig if config.nil?
    if config
      t = config[opt]
      rc = t unless t.nil?
    end
    rc
  end

  def log_in_to_alexa(agent)
    page = agent.get(LOGIN_URL)
    form = page.forms.first
    msg = "\n\n\nPlease set Alexa log in credentials in config/config.yml"
    raise msg unless form['login[email]'] = getoption('email')
    raise msg unless form['login[password]'] = getoption('password')
    form.submit
  end

  def generate_filename(link, ndoc)
    resource_title = ndoc.search('//h1[@class="resource-title"]').text
    (link.href + "__#{resource_title}").gsub(/\W/, '_') + '.html'
  end

  def write_to_file(myfilename, section, ndoc)
    public_dir = 'public'
    Dir.mkdir(public_dir) unless Dir.exist? public_dir
    output_dir = File.join(public_dir, section)
    Dir.mkdir(output_dir) unless Dir.exist? output_dir
    f = File.new(File.join(output_dir, myfilename), 'w')
    f.write(ndoc.to_html)
    f.close
  end

  def get_links_for_section(agent, section)
    page = agent.get("/wdi/march-2015/#{section}")
    page.links.select { |link| link.href =~ %r{wdi/march-2015/#{section}/\d+} }
  end

  def fetch_pages(agent, section)
    get_links_for_section(agent, section)
      .map{ |link| process_link(link, agent, section)}
  end

  def process_link(link, agent, section)
    subpage = agent.get(link.href)
    if subpage.code == '200'
      ndoc = strip_headers_from_document(subpage)
      filename = generate_filename(link, ndoc)
      write_to_file(filename, section, ndoc)
    end
  end

  def strip_headers_from_document(page)
    ndoc = Nokogiri::HTML(page.body)
    ndoc.search("//div[@class='cohort-status-and-calendar-nav']").remove
    ndoc.search('//nav').remove
    ndoc.search('//header[@class="context-header"]').remove
    ndoc.search('//head').remove
    ndoc
  end

  def download
    agent = Mechanize.new
    log_in_to_alexa(agent)
    ['lessons', 'assignments'].map {|s| fetch_pages(agent, s)}
  end
end
