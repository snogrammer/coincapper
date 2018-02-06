[![Gem Version](https://badge.fury.io/rb/coincapper.svg)](https://badge.fury.io/rb/coincapper) [![Build Status](https://travis-ci.org/kurt-smith/coincapper.svg?branch=master)](https://travis-ci.org/kurt-smith/coincapper) [![Code Climate](https://codeclimate.com/github/kurt-smith/coincapper/badges/gpa.svg)](https://codeclimate.com/github/kurt-smith/coincapper) [![Coverage Status](https://coveralls.io/repos/github/kurt-smith/coincapper/badge.svg?branch=master)](https://coveralls.io/github/kurt-smith/coincapper?branch=master) [![Issue Count](https://codeclimate.com/github/kurt-smith/coinmarketcap/badges/issue_count.svg)](https://codeclimate.com/github/kurt-smith/coincapper)

# CoinCapper

An API wrapper to the V1 coinmarketcap.com public API with additional historic, symbol, and market functionality.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'coincapper', '~> 1.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install coincapper

## Usage

### Coinmarketcap.com API responses

#### All Coins

```ruby
CoinCapper.coins(limit: 0, rank:  nil, currency: nil)
```

#### Coin by CoinMarketCap ID

```ruby
CoinCapper.coin('litecoin', currency: nil)
```

#### Global

```ruby
CoinCapper.global(currency: nil)
```

### Additional Functionality

#### Coin by symbol

```ruby
CoinCapper.coin_by_symbol('FUN')

=> {:id=>"funfair",
 :name=>"FunFair",
 :symbol=>"FUN",
 :rank=>"84",
 :price_usd=>"0.0382094",
 :price_btc=>"0.00000557",
 :"24h_volume_usd"=>"5375680.0",
 :market_cap_usd=>"172083246.0",
 :available_supply=>"4503688789.0",
 :total_supply=>"10999873621.0",
 :max_supply=>nil,
 :percent_change_1h=>"-6.89",
 :percent_change_24h=>"-24.77",
 :percent_change_7d=>"-59.6",
 :last_updated=>"1517873357"}
```

#### Available markets by coin id or symbol

```ruby
CoinCapper.coin_markets(id: 'iota', symbol: nil)

=> [{:source=>"Bitfinex", :pair=>"MIOTA/USD", :volume_usd=>33835200.0, :price_usd=>1.41, :volume_percentage=>50.21, :last_updated=>"Recently"},
 {:source=>"Binance", :pair=>"IOTA/BTC", :volume_usd=>7733790.0, :price_usd=>1.41, :volume_percentage=>11.48, :last_updated=>"Recently"}]
```

#### Historical prices by id, start, end date

```ruby
CoinCapper.historical_price('request-network', '2018-01-01', '2018-01-02')

=> [{:date=>"2018-01-02", :open=>0.8126, :high=>0.881387, :low=>0.650608, :close=>0.783648, :average=>0.7659975},
 {:date=>"2018-01-01", :open=>0.606538, :high=>0.888908, :low=>0.528808, :close=>0.820232, :average=>0.708858}]
```

#### All Cryptocurrencies by type (coins, tokens)

```ruby
# coins
CoinCapper.all('coins')

=> [{:id=>"bitcoin",
  :rank=>1,
  :name=>"Bitcoin",
  :symbol=>"BTC",
  :market_cap_usd=>116671271686.0,
  :market_cap_btc=>16848275.0,
  :price_usd=>6924.82,
  :price_btc=>1.0,
  :circulating_supply=>16848275.0,
  :volume_usd_24h=>9116750000.0,
  :volume_btc_24h=>1309170.0,
  :percent_change_1h=>-4.59,
  :percent_change_24h=>-16.75,
  :percent_change_7d=>-38.38}]

# tokens
CoinCapper.all('tokens')

=> [{:id=>"eos",
  :rank=>1,
  :name=>"EOS",
  :platform=>"Ethereum",
  :market_cap_usd=>4598392073.93,
  :market_cap_btc=>663307.647514,
  :price_usd=>7.07817,
  :price_btc=>0.00102101,
  :circulating_supply=>649658326.083,
  :volume_usd_24h=>630722000.0,
  :volume_btc_24h=>90980.3,
  :percent_change_1h=>-6.02,
  :percent_change_24h=>-18.88,
  :percent_change_7d=>-49.0}]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kurt-smith/coincapper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CoinCapper project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/kurt-smith/coincapper/blob/master/CODE_OF_CONDUCT.md).
