require 'rails_helper'

RSpec.describe StatisticsController, type: :controller do
  let(:csv_file) { fixture_file_upload('files/test.csv', 'text/csv') }
  let(:html_file) { fixture_file_upload('files/test.html', 'text/html') }

  describe 'GET index' do
    context 'has a 200 status code' do
      it 'without params' do
        get :index
        expect(response.status).to eq(200)
      end

      it 'with right params' do
        get :index, params: { filename: 'test.csv' }
        expect(response.status).to eq(200)
      end

      it 'with wrong params' do
        get :index, params: { filename_wrong: 'test.csv' }
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'POST upload' do
    context 'success' do
      it 'redirect after file upload with params' do
        post :upload, params: { file: csv_file }
        expect(response).to redirect_to(root_path(filename: 'test.csv'))
      end

      context 'redirect without params' do
        it 'with wrong upload params' do
          post :upload, params: { tmp_file: csv_file }
          expect(response).to redirect_to(root_path)
        end

        it 'without upload params' do
          post :upload
          expect(response).to redirect_to(root_path)
        end
      end
    end

    context 'failure' do
      it 'raise error on wrong file format' do
        expect { post :upload, params: { file: html_file } }.to raise_error('Wrong file format')
      end
    end
  end
end
