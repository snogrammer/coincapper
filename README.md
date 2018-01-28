[![Gem Version](https://badge.fury.io/rb/coincapper.svg)](https://badge.fury.io/rb/coincapper) [![Build Status](https://travis-ci.org/kurt-smith/coincapper.svg?branch=master)](https://travis-ci.org/kurt-smith/coincapper) [![Code Climate](https://codeclimate.com/github/kurt-smith/coincapper/badges/gpa.svg)](https://codeclimate.com/github/kurt-smith/coincapper) [![Coverage Status](https://coveralls.io/repos/github/kurt-smith/coincapper/badge.svg?branch=master)](https://coveralls.io/github/kurt-smith/coincapper?branch=master) [![Issue Count](https://codeclimate.com/github/kurt-smith/coinmarketcap/badges/issue_count.svg)](https://codeclimate.com/github/kurt-smith/coincapper)

# CoinCapper

An API wrapper to the V1 coinmarketcap.com public API with additional historic, symbol, and market functionality.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'coincapper', '~> 1.0'

- or -

gem 'coincapper', git: 'https://github.com/kurt-smith/coincapper', branch: 'master' # feature branches
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

#### Coin by Coin Market Cap ID

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
```

#### Retrieve markets by coin

```ruby
CoinCapper.coin_markets(id: 'iota', symbol: nil)
```

#### Retrieve Coin historical price

```ruby
CoinCapper.historical_price('request-network', '2018-01-01', '2018-01-08')
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
