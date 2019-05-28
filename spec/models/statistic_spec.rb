require 'rails_helper'

RSpec.describe Statistic, type: :model do
  let(:valid_csv_array) do
    [
      { 'Date' => '01.04.2019', 'CardType' => 'Atr', 'SalesCount' => '25' },
      { 'Date' => '01.04.2019', 'CardType' => 'Blt', 'SalesCount' => '34' },
      { 'Date' => '01.04.2019', 'CardType' => 'Cop', 'SalesCount' => '23' },
      { 'Date' => '02.04.2019', 'CardType' => 'Blt', 'SalesCount' => '4' },
      { 'Date' => '02.04.2019', 'CardType' => 'COP', 'SalesCount' => '48' },
      { 'Date' => '04.04.2019', 'CardType' => 'Blt', 'SalesCount' => '123' },
      { 'Date' => '04.04.2019', 'CardType' => 'BLT', 'SalesCount' => '15' },
      { 'Date' => '07.04.2019', 'CardType' => 'ATr', 'SalesCount' => '12' },
      { 'Date' => '07.04.2019', 'CardType' => 'Cop', 'SalesCount' => '0' }
    ]
  end
  let(:parse_table_array) do
    [
      %w[Date Atr Blt Cop],
      ['01.04.2019', 25, 34, 23],
      ['02.04.2019', 0, 4, 48],
      ['04.04.2019', 0, 138, 0],
      ['07.04.2019', 12, 0, 0]
    ]
  end

  describe '#parse_csv' do
    let(:csv_file) { fixture_file_upload('files/test.csv', 'text/csv') }
    let(:missing_data_csv_file) { fixture_file_upload('files/missing_test.csv', 'text/csv') }
    let(:html_file) { fixture_file_upload('files/test.html', 'text/html') }

    context 'success' do
      it 'parse right data' do
        parse_response = Statistic.parse_csv(csv_file)
        expect(parse_response[:csv_data]).to eq(valid_csv_array)
        expect(parse_response[:errors_count]).to eq(0)
      end

      it 'parse not full data' do
        valid_result = [
            { 'Date' => '01.04.2019', 'CardType' => 'Atr', 'SalesCount' => '25' },
            { 'Date' => '01.04.2019', 'CardType' => 'Blt', 'SalesCount' => '34' },
            { 'Date' => '02.04.2019', 'CardType' => 'COP', 'SalesCount' => '48' },
            { 'Date' => '07.04.2019', 'CardType' => 'ATr', 'SalesCount' => '12' },
            { 'Date' => '07.04.2019', 'CardType' => 'Cop', 'SalesCount' => '0' }
        ]
        parse_response = Statistic.parse_csv(missing_data_csv_file)
        expect(parse_response[:csv_data]).to eq(valid_result)
        expect(parse_response[:errors_count]).to eq(4)
      end
    end

    context 'failure' do
      it 'raise error on wrong file format' do
        expect { Statistic.parse_csv(html_file) }.to raise_error(RuntimeError, 'Wrong file format')
      end
    end
  end

  describe '#parse_table_data' do
    context 'success' do
      it 'return right array' do
        expect(Statistic.parse_table_data(valid_csv_array)).to eq(parse_table_array)
      end
    end
  end

  describe '#sanitize_table_data' do
    context 'success' do
      it 'add average count for entries with count eq 0' do
        result_array = [
            %w[Date Atr Blt Cop],
            ['01.04.2019', 25, 34, 23],
            ['02.04.2019', 12, 4, 48],
            ['04.04.2019', 12, 138, 24],
            ['07.04.2019', 12, 69, 12]
        ]

        expect(Statistic.sanitize_table_data(parse_table_array)).to eq(result_array)
      end

      it 'with first and last element contain 0 values' do
        original_array = [
            %w[Date Atr Blt Cop Abz Xcz],
            ['01.04.2019', 25, 34, 23, 0, 0],
            ['02.04.2019', 0, 4, 48, 2, 0],
            ['04.04.2019', 0, 138, 5, 20, 0],
            ['07.04.2019', 12, 0, 0, 0, 0]
        ]

        result_array = [
            %w[Date Atr Blt Cop Abz Xcz],
            ['01.04.2019', 25, 34, 23, 1, 0],
            ['02.04.2019', 12, 4, 48, 2, 0],
            ['04.04.2019', 12, 138, 5, 20, 0],
            ['07.04.2019', 12, 69, 2, 10, 0]
        ]

        expect(Statistic.sanitize_table_data(original_array)).to eq(result_array)
      end
    end
  end
end
