require 'csv'

class Statistic < ApplicationRecord

  def self.parse_csv(file)
    raise('Wrong file format') if File.extname(file) != '.csv'

    csv = []
    errors_count = 0
    csv_test = File.read(Rails.root.join('storage', file))

    CSV.parse(csv_test, headers: true) do |row|
      new_row = {}
      row.to_h.map { |k, v| new_row[k&.strip] = v&.strip }

      # do not save row in case of empty/nil value
      if new_row.values.map(&:blank?).include?(true)
        errors_count += 1
      else
        csv << new_row
      end
    end

    { csv_data: csv, errors_count: errors_count }
  end
end
