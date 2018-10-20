# frozen_string_literal: true

require 'spec_helper'

describe CoinCapper do
  it { expect(CoinCapper::VERSION).to eq('1.2.0') }

  describe '#coins' do
    it 'returns all coins on default' do
      stub_request(:get, /ticker/).and_return(body: fixture('coins.json'))
      response = described_class.coins
      expect(a_request(:get, /ticker\/\?limit=0/)).to have_been_made.once
      expect(response.first).to be_a(Hash)
    end

    it 'returns coins starting with rank' do
      stub_request(:get, /ticker/).and_return(body: fixture('coins_with_rank.json'))
      response = described_class.coins(rank: 30)
      expect(a_request(:get, /ticker\/\?limit=0\&start=30/)).to have_been_made.once
      expect(response.first).to be_a(Hash)
    end

    it 'returns coins converted to currency' do
      stub_request(:get, /ticker/).and_return(body: fixture('coins_with_currency.json'))
      response = described_class.coins(currency: 'EUR')
      expect(a_request(:get, /ticker\/\?convert=EUR\&limit=0/)).to have_been_made.once
      expect(response.first).to be_a(Hash)
    end
  end

  describe '#coin' do
    it 'returns coin info' do
      stub_request(:get, /ticker\/bitcoin/).and_return(body: fixture('coin.json'))
      response = described_class.coin('bitcoin')
      expect(a_request(:get, /ticker\/bitcoin/)).to have_been_made.once
      expect(response).to be_a(Hash)
    end

    it 'returns coin with convert currency' do
      stub_request(:get, /ticker\/bitcoin/).and_return(body: fixture('coin.json'))
      response = described_class.coin('bitcoin', currency: 'EUR')
      expect(a_request(:get, /ticker\/bitcoin\/\?convert=EUR/)).to have_been_made.once
      expect(response).to be_a(Hash)
    end

    it 'returns coin error' do
      stub_request(:get, /ticker\/bitco/).and_return(body: fixture('coin_error.json'))
      response = described_class.coin('bitco')
      expect(a_request(:get, /ticker\/bitco/)).to have_been_made.once
      expect(response).to be_a(Hash)
    end
  end

  describe '#coin_by_symbol' do
    it 'returns coin' do
      stub_request(:get, /ticker/).and_return(body: fixture('coins.json'))
      response = described_class.coin_by_symbol('miota')
      expect(a_request(:get, /ticker\/\?limit=0/)).to have_been_made.once
      expect(response).to be_a(Hash)
      expect(response).not_to be_empty
    end
  end

  describe '#coin_markets' do
    it 'returns markets by id' do
      stub_request(:get, /currencies\/litecoin\/\#markets/).and_return(body: fixture('coin_markets.html'))
      response = described_class.coin_markets(id: 'litecoin')
      expect(a_request(:get, /currencies\/litecoin\/\#markets/)).to have_been_made.once
      expect(response).to be_a(Array)
      expect(response.count).to eq(16)
      expect(response.first).to eq(
        source: 'Binance',
        pair: 'IOTA/BTC',
        volume_usd: 97_152_900.0,
        price_usd: 4.13,
        volume_percentage: 38.17,
        last_updated: 'Recently'
      )
    end

    it 'returns markets by symbol' do
      stub_request(:get, /currencies\/litecoin\/\#markets/).and_return(body: fixture('coin_markets.html'))
      stub_request(:get, /ticker/).and_return(body: fixture('coins.json'))

      response = described_class.coin_markets(symbol: 'LTC')
      expect(a_request(:get, /ticker\/\?limit=0/)).to have_been_made.once
      expect(a_request(:get, /currencies\/litecoin\/\#markets/)).to have_been_made.once
      expect(response).to be_a(Array)
      expect(response.count).to eq(16)
      expect(response.first).to eq(
        source: 'Binance',
        pair: 'IOTA/BTC',
        volume_usd: 97_152_900.0,
        price_usd: 4.13,
        volume_percentage: 38.17,
        last_updated: 'Recently'
      )
    end

    it do
      expect { described_class.coin_markets }.to raise_error(ArgumentError, 'id or symbol is required')
    end
  end

  describe '#global' do
    it 'returns global info' do
      stub_request(:get, /global/).and_return(body: fixture('global.json'))
      response = described_class.global
      expect(a_request(:get, /global/)).to have_been_made.once
      expect(response).to be_a(Hash)
    end

    it 'returns global with convert currency' do
      stub_request(:get, /global/).and_return(body: fixture('global.json'))
      response = described_class.global(currency: 'EUR')
      expect(a_request(:get, /global\/\?convert=EUR/)).to have_been_made.once
      expect(response).to be_a(Hash)
    end
  end

  describe '#historical_price' do
    it 'parses html and returns prices' do
      stub_request(:get, /historical-data/).and_return(body: fixture('historical_price.html'))
      response = described_class.historical_price('request-network', '2018-01-02', '2018-01-08')
      expect(a_request(:get, /currencies\/request-network\/historical-data\/\?end=20180108\&start=20180102/)).to have_been_made.once
      expect(response).to be_a(Array)
      expect(response.first).to be_a(Hash)
      expect(response.first).to eq(
        date: '2018-01-07',
        open: 0.97823,
        high: 1.05,
        low: 0.92497,
        close: 0.935619,
        volume: 24.0,
        market_cap: 626.0,
        average: 0.987485
      )
    end

    it 'returns error when dates are invalid' do
      expect(described_class.historical_price('fun', 'invalid', '2018-01-08'))
        .to eq(error: 'invalid date format')
    end

    it 'returns error when id returns blank table' do
      stub_request(:get, /historical-data/).and_return(body: '')
      response = described_class.historical_price('request-network', '2018-01-02', '2018-01-08')
      expect(response).to eq(error: 'invalid id')
    end
  end

  describe '#all' do
    context 'coins' do
      it 'returns list' do
        stub_request(:get, %r{/coins/views}).and_return(body: fixture('all_coins.html'))
        response = described_class.all('coins')
        expect(a_request(:get, %r{/coins/views/all})).to have_been_made.once
        expect(response).to be_a(Array)
        expect(response.first).to be_a(Hash)
        expect(response.first).to eq(id: 'bitcoin',
                                     rank: 1,
                                     name: 'Bitcoin',
                                     symbol: 'BTC',
                                     market_cap_usd: 123_191_330_221.0,
                                     market_cap_btc: 16_848_037.0,
                                     price_usd: 7311.91,
                                     price_btc: 1.0,
                                     circulating_supply: 16_848_037.0,
                                     volume_usd_24h: 8_939_660_000.0,
                                     volume_btc_24h: 1_224_330.0,
                                     percent_change_1h: 6.24,
                                     percent_change_24h: -10.83,
                                     percent_change_7d: -35.28)
      end
    end

    context 'tokens' do
      it 'returns list' do
        stub_request(:get, %r{/tokens/views}).and_return(body: fixture('all_tokens.html'))
        response = described_class.all('tokens')
        expect(a_request(:get, %r{/tokens/views/all})).to have_been_made.once
        expect(response).to be_a(Array)
        expect(response.first).to be_a(Hash)
        expect(response.first).to eq(id: 'eos',
                                     rank: 1,
                                     name: 'EOS',
                                     platform: 'Ethereum',
                                     market_cap_usd: 4_953_845_106.1,
                                     market_cap_btc: 678_455.759902,
                                     price_usd: 7.62533,
                                     price_btc: 0.00104433,
                                     circulating_supply: 649_656_487.798,
                                     volume_usd_24h: 638_682_000.0,
                                     volume_btc_24h: 87_470.5,
                                     percent_change_1h: 6.59,
                                     percent_change_24h: -11.73,
                                     percent_change_7d: -45.64)
      end
    end
  end
end
