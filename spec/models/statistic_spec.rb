require 'rails_helper'

RSpec.describe Statistic, type: :model do

  describe '#parse_csv' do
    let(:csv_file) { fixture_file_upload('files/test.csv', 'text/csv') }
    let(:missing_data_csv_file) { fixture_file_upload('files/missing_test.csv', 'text/csv') }
    let(:html_file) { fixture_file_upload('files/test.html', 'text/html') }

    context 'success' do
      it 'parse right data' do
        valid_result = [
            { 'Date' => '01.04.2019', 'CardType' => 'Atr', 'SalesCount' => '25' },
            { 'Date' => '01.04.2019', 'CardType' => 'Blt', 'SalesCount' => '34' },
            { 'Date' => '01.04.2019', 'CardType' => 'Cop', 'SalesCount' => '23' },
            { 'Date' => '02.04.2019', 'CardType' => 'Blt', 'SalesCount' => '4' },
            { 'Date' => '02.04.2019', 'CardType' => 'Cop', 'SalesCount' => '48' },
            { 'Date' => '04.04.2019', 'CardType' => 'Blt', 'SalesCount' => '123' },
            { 'Date' => '04.04.2019', 'CardType' => 'Blt', 'SalesCount' => '15' },
            { 'Date' => '07.04.2019', 'CardType' => 'Atr', 'SalesCount' => '12' },
            { 'Date' => '07.04.2019', 'CardType' => 'Cop', 'SalesCount' => '0' }
        ]
        parse_response = Statistic.parse_csv(csv_file)
        expect(parse_response[:csv_data]).to eq(valid_result)
        expect(parse_response[:errors_count]).to eq(0)
      end

      it 'parse not full data' do
        valid_result = [
            { 'Date' => '01.04.2019', 'CardType' => 'Atr', 'SalesCount' => '25' },
            { 'Date' => '01.04.2019', 'CardType' => 'Blt', 'SalesCount' => '34' },
            { 'Date' => '02.04.2019', 'CardType' => 'Cop', 'SalesCount' => '48' },
            { 'Date' => '07.04.2019', 'CardType' => 'Atr', 'SalesCount' => '12' },
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
        original_array = [
            { 'Date' =>'01.04.2019', 'CardType' =>'Atr', 'SalesCount' =>'25' },
            { 'Date' =>'01.04.2019', 'CardType' =>'Blt', 'SalesCount' =>'34' },
            { 'Date' =>'01.04.2019', 'CardType' =>'Cop', 'SalesCount' =>'23' },
            { 'Date' =>'02.04.2019', 'CardType' =>'Blt', 'SalesCount' =>'4' },
            { 'Date' =>'02.04.2019', 'CardType' =>'Cop', 'SalesCount' =>'48' },
            { 'Date' =>'04.04.2019', 'CardType' =>'Blt', 'SalesCount' =>'123' },
            { 'Date' =>'04.04.2019', 'CardType' =>'Blt', 'SalesCount' =>'15' },
            { 'Date' =>'07.04.2019', 'CardType' =>'Atr', 'SalesCount' =>'12' },
            { 'Date' =>'07.04.2019', 'CardType' =>'Cop', 'SalesCount' =>'0'}
        ]
        result_array = [
            %w['Date' 'Atr' 'Blt' 'Cop'],
            %w['01.04.2019' '25' '34' '23'],
            %w['02.04.2019' '12,5' '4' '48'],
            %w['04.04.2019' '12.25' '138' '24'],
            %w['07.04.2019' '12' '69' '12']
        ]

        expect(Statistic.parse_table_data(original_array)).to eq(result_array)
      end
    end

    context 'failure' do

    end
  end
end
