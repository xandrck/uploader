require 'csv'

class Statistic < ApplicationRecord

  def self.parse_csv(file)
    raise('Wrong file format') if File.extname(file) != '.csv'

    csv = []
    errors_count = 0
    csv_test = File.read(Rails.root.join('storage', file))

    CSV.parse(csv_test, headers: true) do |row|
      new_row = {}
      row.to_h.map { |k, v| new_row[k&.strip] = v&.strip&.capitalize }

      # do not save row in case of empty/nil value
      if new_row.values.map(&:blank?).include?(true)
        errors_count += 1
      else
        csv << new_row
      end
    end

    { csv_data: csv, errors_count: errors_count }
  end

  def self.parse_table_data(array)
    table_data = []
    unique_types = array.collect { |e| e['CardType'] }.uniq
    table_data << ['Date'].concat(unique_types)

    hash = array.group_by { |e| e['Date'] }
    result_array = [].concat(table_data)

    hash.each do |k, v|
      # (unique_types.count + 1) it's a count of all unique data types + date column
      temp_array = Array.new(unique_types.count + 1, 0)
      temp_array[0] = k

      v.each do |el|
        table_data.first
        index = table_data.first.find_index(el['CardType'])
        temp_array[index] = el['SalesCount'].to_i
      end

      result_array << temp_array
    end
    result_array
  end
end
