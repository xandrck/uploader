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
    uploaded_io = params[:file]
    raise('Wrong file format') if File.extname(uploaded_io.original_filename) != '.csv'

    File.open(Rails.root.join('storage', uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end

    filename = params[:file].original_filename
    redirect_to root_path(filename: filename)
  end
end
