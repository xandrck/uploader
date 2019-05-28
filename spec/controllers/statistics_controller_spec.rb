require 'rails_helper'

RSpec.describe StatisticsController, type: :controller do

  describe 'GET index' do
    it 'has a 200 status code' do
      get :index
      expect(response.status).to eq(200)
    end
  end

  describe 'POST upload' do
    let(:csv_file) { fixture_file_upload('files/test.csv', 'text/csv') }
    let(:html_file) { fixture_file_upload('files/test.html', 'text/html') }

    it 'success' do
      post :upload, params: { file: csv_file }
      expect(response).to be_redirect
    end

    it 'failure' do
      expect { post :upload, params: { file: html_file } }.to raise_error('Wrong file format')
    end
  end
end
