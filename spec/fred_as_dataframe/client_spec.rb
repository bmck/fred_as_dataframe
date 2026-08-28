require 'spec_helper'

RSpec.describe FredAsDataframe::Client do
  let(:api_key) { 'test_api_key_1234567890' }
  let(:series) { 'UNRATE' }

  describe '.configure' do
    it 'sets the api_key via configuration block' do
      described_class.configure do |config|
        config.api_key = api_key
      end

      expect(described_class.api_key).to eq(api_key)
    end
  end

  describe '.api_key' do
    it 'can be set and retrieved' do
      described_class.api_key = api_key
      expect(described_class.api_key).to eq(api_key)
    end
  end

  describe '#initialize' do
    context 'with api_key from class variable' do
      before do
        described_class.api_key = api_key
      end

      it 'creates a client with the specified series' do
        client = described_class.new(series)
        expect(client.tag).to eq(series)
      end

      it 'uses the class-level api_key' do
        client = described_class.new(series)
        expect(client.instance_variable_get(:@api_key)).to eq(api_key)
      end
    end

    context 'with api_key from environment variable' do
      before do
        stub_const('ENV', ENV.to_hash.merge('FRED_API_KEY' => api_key))
        described_class.api_key = nil
      end

      it 'can use api_key from options' do
        client = described_class.new(series, api_key: 'override_key')
        expect(client.instance_variable_get(:@api_key)).to eq('override_key')
      end
    end

    context 'with api_key passed as option' do
      it 'prefers the option api_key over class variable' do
        described_class.api_key = 'class_key'
        client = described_class.new(series, api_key: 'option_key')
        expect(client.instance_variable_get(:@api_key)).to eq('option_key')
      end
    end
  end

  describe '#fetch', :vcr do
    before do
      described_class.api_key = api_key
    end

    let(:client) { described_class.new(series) }

    context 'with valid series' do
      it 'returns a Polars DataFrame' do
        VCR.use_cassette('unrate_full') do
          result = client.fetch
          expect(result).to be_a(Polars::DataFrame)
        end
      end

      it 'has the correct columns' do
        VCR.use_cassette('unrate_full') do
          result = client.fetch
          expect(result.columns).to eq(['Timestamps', 'UNRATE'])
        end
      end

      it 'contains data' do
        VCR.use_cassette('unrate_full') do
          result = client.fetch
          expect(result.height).to be > 0
        end
      end
    end

    context 'with start date filter' do
      it 'filters data from the start date' do
        VCR.use_cassette('unrate_full') do
          result = client.fetch(start: '2020-01-01')
          timestamps = result['Timestamps'].to_a
          expect(timestamps.min).to be >= Date.parse('2020-01-01')
        end
      end
    end

    context 'with end date filter' do
      it 'filters data to the end date' do
        VCR.use_cassette('unrate_full') do
          result = client.fetch(fin: '2020-12-31')
          timestamps = result['Timestamps'].to_a
          expect(timestamps.max).to be <= Date.parse('2020-12-31')
        end
      end
    end

    context 'with both start and end date filters' do
      it 'filters data within the date range' do
        VCR.use_cassette('unrate_full') do
          result = client.fetch(start: '2020-01-01', fin: '2020-12-31')
          timestamps = result['Timestamps'].to_a
          expect(timestamps.min).to be >= Date.parse('2020-01-01')
          expect(timestamps.max).to be <= Date.parse('2020-12-31')
        end
      end
    end

    context 'with SP500 series' do
      let(:series) { 'SP500' }

      it 'returns hardcoded SP500 data' do
        result = client.fetch(interval: '1m')
        expect(result).to be_a(Polars::DataFrame)
        expect(result.columns).to eq(['Timestamps', 'SP500'])
        expect(result.height).to be > 0
      end
    end

    context 'with invalid series' do
      let(:invalid_client) { described_class.new('INVALID_SERIES_XYZ') }

      it 'raises an IOError with helpful message' do
        VCR.use_cassette('invalid_series') do
          expect { invalid_client.fetch }.to raise_error(IOError, /Failed to get the data/)
        end
      end

      it 'includes the series name in error message' do
        VCR.use_cassette('invalid_series') do
          expect { invalid_client.fetch }.to raise_error(IOError, /INVALID_SERIES_XYZ/)
        end
      end
    end
  end

  describe 'private methods' do
    let(:client) { described_class.new(series) }

    before do
      described_class.api_key = api_key
    end

    describe '#_url' do
      it 'constructs the correct API URL' do
        url = client.send(:_url, series, 'm')
        expect(url).to include('https://api.stlouisfed.org/fred/series/observations')
        expect(url).to include("series_id=#{series}")
        expect(url).to include("api_key=#{api_key}")
        expect(url).to include('frequency=m')
      end

      it 'omits frequency parameter for daily interval' do
        url = client.send(:_url, series, 'd')
        expect(url).to include('https://api.stlouisfed.org/fred/series/observations')
        expect(url).not_to include('frequency=')
      end
    end
  end
end
