class StatisticsController < ApplicationController
  def index
    @statistic = {}

    if params[:filename]
      file_exist = File.file?(Rails.root.join('storage', params[:filename]))
      valid_format = File.extname(params[:filename]) == '.csv'

      @statistic = Statistic.parse_csv_to_data(params[:filename]) if file_exist && valid_format
    end
  end

  def upload
    path = root_path

    if params[:file]
      uploaded_io = params[:file]
      raise('Wrong file format') if File.extname(uploaded_io.original_filename) != '.csv'

      # saving file to storage to reduce path length instead of using tmp file path
      # it will also cause to use storage path for test
      File.open(Rails.root.join('storage', uploaded_io.original_filename), 'wb') do |file|
        file.write(uploaded_io.read)
      end

      filename = params[:file].original_filename
      path = root_path(filename: filename)
    end

    redirect_to path
  end
end
