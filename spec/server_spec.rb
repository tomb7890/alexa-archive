require 'spec_helper'
require 'rack/test'

describe Server do
  let(:app) { Server.new }

  context 'GET to /' do
    let(:response) { get '/' }
    it 'returns status 200 OK' do
      expect(response.status).to eq 200
      expect(response.body).to include('Assignments')
      expect(response.body).to include('Lessons')
    end
  end

  context 'GET to /lessons' do
    let(:response) { get '/lessons' }
    it 'returns status 200 OK' do
      expect(response.status).to eq 200
      expect(response.body).to include('OS and Git Fundamentals')
      expect(response.body).to include('Good Friday: NO LESSON')
    end
  end

  context 'GET to /lessons/508' do
    let(:response) { get '/lessons/508' }
    it 'returns status 200 OK' do
      expect(response.status).to eq 200
      expect(response.body).to include('CSS3 allows you to use 2D/3D transforms to manipulate DOM objects')
    end
  end
end
