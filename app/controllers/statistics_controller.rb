class StatisticsController < ApplicationController
  def index
    @errors = nil
    @csv_data = nil
    @chart_statistics = nil

    if params[:filename]
      file_exist = File.file?(Rails.root.join('storage', params[:filename]))
      valid_format = File.extname(params[:filename]) == '.csv'

      statistics = []
      statistics = Statistic.parse_csv(params[:filename]) if file_exist && valid_format

      @errors = statistics[:errors_count]
      @csv_data = statistics[:csv_data]

      @chart_statistics = Statistic.parse_table_data(@csv_data)
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
