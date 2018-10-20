# frozen_string_literal: false

require 'active_support'
require 'active_support/core_ext'
require 'coincapper/version'
require 'http'
require 'nokogiri'

class CoinCapper
  API_URL = 'https://api.coinmarketcap.com/v1'.freeze
  BASE_URL = 'https://coinmarketcap.com'.freeze

  class << self
    # @param rank [Integer] Coins market cap rank greater than or equal
    # @param limit [Integer] Maximum limit set. Defaults to 0 to return all results
    # @param currency [String] Country currency code to convert price
    # @return [Array<Hash>]
    # @see https://coinmarketcap.com/api/
    def coins(limit: 0, rank: nil, currency: nil)
      params = {
        limit: limit,
        start: rank,
        convert: currency
      }.compact.to_param

      url = "#{API_URL}/ticker/"
      url << "?#{params}" if params.present?

      response = HTTP.get(url)
      JSON.parse(response.body.to_s, symbolize_names: true)
    end

    # @param id [Integer] Coinmarketcap coin id
    # @param currency [String] Country currency code to convert price
    # @return [Hash]
    def coin(id, currency: nil)
      params = {
        convert: currency
      }.compact.to_param

      url = "#{API_URL}/ticker/#{id}/"
      url << "?#{params}" if params.present?

      response = HTTP.get(url)
      json = JSON.parse(response.body.to_s, symbolize_names: true)
      json.is_a?(Array) ? json.first : json
    end

    # @param symbol [String] Coin symbol
    # @return [Hash]
    def coin_by_symbol(symbol)
      response = HTTP.get("#{API_URL}/ticker/?limit=0")
      json = JSON.parse(response.body.to_s, symbolize_names: true)
      json.find { |x| x[:symbol].strip.casecmp(symbol.strip.upcase).zero? }
    end

    # @param id [String] Coin market cap id
    # @param symbol [String] Coin symbol
    # @return [Array<Hash>]
    def coin_markets(id: nil, symbol: nil)
      raise ArgumentError.new('id or symbol is required') if id.blank? && symbol.blank?

      coin_id = symbol.present? ? coin_by_symbol(symbol)[:id] : id
      response = HTTP.get("#{BASE_URL}/currencies/#{coin_id}/\#markets")
      html = Nokogiri::HTML(response.body.to_s)
      rows = html.css('table#markets-table tbody tr')
      return { error: 'invalid id' } if rows.blank?

      markets = rows.each_with_object([]) do |row, arr|
        td = row.css('td')
        arr << {
          source: td[1].text.strip,
          pair: td[2].text.strip,
          volume_usd: td[3].text.strip[/\$(.+)/, 1].delete(',').to_f,
          price_usd: td[4].text.strip[/\$(.+)/, 1].delete(',').to_f,
          volume_percentage: td[5].text.to_f,
          last_updated: td[6].text.strip
        }
      end

      markets
    end

    # @param currency [String] Country currency code to convert price
    # @return [Hash]
    def global(currency: nil)
      params = {
        convert: currency
      }.compact.to_param

      url = "#{API_URL}/global/"
      url << "?#{params}" if params.present?

      response = HTTP.get(url)
      JSON.parse(response.body.to_s, symbolize_names: true)
    end

    # @param id [String] Coinmarketcap coin id
    # @param start_date [String] Start date (YYYY-MM-DD)
    # @param end_date [String] End date (YYYY-MM-DD)
    # @return [Array<Hash>]
    def historical_price(id, start_date, end_date)
      sd = parse_date(start_date, format: '%Y%m%d')
      ed = parse_date(end_date, format: '%Y%m%d')
      return { error: 'invalid date format' } if sd.blank? || ed.blank?

      url = "#{BASE_URL}/currencies/#{id}/historical-data/?start=#{sd}&end=#{ed}"
      response = HTTP.get(url)
      html = Nokogiri::HTML(response.body.to_s)
      rows = html.css('#historical-data table tbody tr')
      return { error: 'invalid id' } if rows.blank?

      prices = rows.each_with_object([]) do |row, arr|
        td = row.css('td')
        daily = {
          date: parse_date(td[0].text, format: '%F'),
          open: td[1].text.delete(',').to_f,
          high: td[2].text.delete(',').to_f,
          low: td[3].text.delete(',').to_f,
          close: td[4].text.delete(',').to_f,
          volume: td[5].text.delete(',').to_f,
          market_cap: td[6].text.delete(',').to_f
        }

        daily[:average] = ((daily[:high] + daily[:low]).to_d / 2).to_f
        arr << daily
      end

      prices
    end

    # Returns list of cryptocurrencies by type (coins, tokens)
    # @param type [String] Cryptocurrency type. i.e. 'coins' or 'tokens'
    # @return [Array<Hash>] List of all coins (or tokens)
    def all(type)
      return { error: 'invalid type' } unless /coins|tokens/ =~ type

      url = "#{BASE_URL}/#{type}/views/all/"
      response = HTTP.get(url)
      html = Nokogiri::HTML(response.body.to_s)
      table = html.css('table#currencies-all, table#assets-all')
      rows = table.css('tbody tr')

      cryptos = rows.each_with_object([]) do |row, arr|
        td = row.css('td')
        arr << {
          id: row&.attribute('id')&.text[/id-(.+)/, 1],
          rank: td[0].text.to_i,
          name: td[1].css('a.currency-name-container').text.strip,
          symbol: type.eql?('coins') ? td[2].text : nil,
          platform: type.eql?('tokens') ? td[2].text : nil,
          market_cap_usd: td[3]&.attribute('data-usd')&.text.to_f,
          market_cap_btc: td[3]&.attribute('data-btc')&.text.to_f,
          price_usd: td[4].css('a.price')&.attribute('data-usd')&.text.to_f,
          price_btc: td[4].css('a.price')&.attribute('data-btc')&.text.to_f,
          circulating_supply: td[5].css('a, span')&.attribute('data-supply')&.text.to_f,
          volume_usd_24h: td[6].css('a')&.attribute('data-usd')&.text.to_f,
          volume_btc_24h: td[6].css('a')&.attribute('data-btc')&.text.to_f,
          percent_change_1h: td[7]&.attribute('data-usd')&.text.to_f,
          percent_change_24h: td[8]&.attribute('data-usd')&.text.to_f,
          percent_change_7d: td[9]&.attribute('data-usd')&.text.to_f
        }.compact
      end

      cryptos
    rescue StandardError => e
      {
        message: 'An unknown error occurred. Please submit a GitHub issue if problem continues.',
        error: e.message
      }
    end

    private

    def parse_date(date, format: nil)
      d = Date.parse(date)
      return d if format.blank?
      d.strftime(format)
    rescue StandardError
      nil
    end
  end
end
