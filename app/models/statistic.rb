require 'csv'

class Statistic < ApplicationRecord

  def self.parse_csv_to_data(file)
    csv_response = parse_csv(file)
    parsed_data = parse_table_data(csv_response[:csv_data])
    csv_response[:chart] = sanitize_table_data(parsed_data)
    csv_response
  end

  def self.parse_csv(file)
    raise('Wrong file format') if File.extname(file) != '.csv'

    csv_array = []
    errors_count = 0
    csv_test = File.read(Rails.root.join('storage', file))

    CSV.parse(csv_test, headers: true) do |row|
      new_row = {}
      row.to_h.map { |k, v| new_row[k&.strip] = v&.strip }

      # do not save row in case of empty/nil value
      if new_row.values.map(&:blank?).include?(true)
        errors_count += 1
      else
        csv_array << new_row
      end
    end

    { csv_data: csv_array, errors_count: errors_count }
  end

  def self.parse_table_data(array)
    unique_types = array.collect { |e| e['CardType'] }.map(&:capitalize).uniq

    # add headers
    result_array = [['Date'].concat(unique_types)]
    hash = array.group_by { |e| e['Date'] }

    hash.each do |k, v|
      # (unique_types.count + 1) it's a count of all unique data types + date column
      temp_array = Array.new(unique_types.count + 1, 0)
      temp_array[0] = k

      v.each do |el|
        result_array.first
        index = result_array.first.find_index(el['CardType'].capitalize)
        temp_array[index] = temp_array[index] + el['SalesCount'].to_i
      end

      result_array << temp_array
    end

    result_array
  end

  # set average count value of card_type in case if count = 0
  def self.sanitize_table_data(array)
    array.each_with_index do |value, root_index|
      if value.include?(0)
        value.each_with_index do |el, i|
          if el == 0
            prev_element = array[root_index - 1].present? ? array[root_index - 1][i] : 0
            next_element = array[root_index + 1].present? ? array[root_index + 1][i] : 0
            value[i] = (prev_element + next_element)/2
          end
        end
      end
    end

    array
  end
end
