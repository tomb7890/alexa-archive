require 'spec_helper'

require 'rack/test'

describe Downloader do
  let(:s) { Downloader.new }

  context 'GET to /' do
    it 'verifies expected numbers of links' do

      agent = Mechanize.new
      s.log_in_to_alexa(agent)

      section = 'lessons'
      links = s.get_links_for_section(agent, section)
      expect(links.size).to eq 45

      section = 'assignments'
      links = s.get_links_for_section(agent, section)
      expect(links.size).to eq 24
    end
  end
end 
