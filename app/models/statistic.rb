require 'csv'

class Statistic < ApplicationRecord

  def self.parse_csv(file)
    raise('Wrong file format') if File.extname(file) != '.csv'

    csv = []
    csv_test = File.read(Rails.root.join('storage', file))

    CSV.parse(csv_test, headers: true) do |row|
      new_row = {}
      row.to_h.map { |k, v| new_row[k.strip] = v.strip }
      csv << new_row
    end

    csv
  end
end
