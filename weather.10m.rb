#!/usr/bin/env ruby

# <xbar.title>Weather Widget</xbar.title>
# <xbar.version>v0.3</xbar.version>
# <xbar.author>Paul Lahana</xbar.author>
# <xbar.author.github>paultursuru</xbar.author.github>
# <xbar.desc>Weather widget for me</xbar.desc>
# <xbar.dependencies>ruby, json</xbar.dependencies>
# <xbar.var>string(VAR_POSTAL_CODE="1007"): Code postal suisse (ex. 1007 pour Lausanne, 1201 pour Genève).</xbar.var>

require 'json'
require 'open-uri'
require 'date'
require 'base64'

METEO_SUISSE_HOST = "https://www.meteosuisse.admin.ch"
POSTAL_CODE = ENV.fetch('VAR_POSTAL_CODE', '1007').strip

# Looks the postal code up in the search index used by the MeteoSuisse website, split by the
# first two digits of the postal code. Each entry looks like:
# "100700;VD;<de path>;/previsions-locales/lausanne/1007.html;<it path>;<en path>;0;1007;2;Lausanne;3;Losanna;city"
# The location id is the postal code followed by a two-digit suffix: 00 for the main locality,
# 01, 02… for the others sharing the postal code (a few postal codes have no 00).
def find_location(postal_code)
  index = JSON.parse(URI.open("#{METEO_SUISSE_HOST}/static/resources/local-forecast-search/#{postal_code[0, 2]}.json").read)
  fields = index.map { |entry| entry.split(';') }
                .select { |entry_fields| entry_fields[7] == postal_code }
                .min_by(&:first)
  return unless fields

  names = fields[8...-1].each_slice(2).to_h # language code => name, "2" is French
  { id: fields[0], name: names['2'] || names.values.first, url: "#{METEO_SUISSE_HOST}#{fields[3]}" }
rescue OpenURI::HTTPError
  nil
end

location = find_location(POSTAL_CODE)
unless location
  puts "⚠️ Météo"
  puts "---"
  puts "Code postal « #{POSTAL_CODE} » inconnu de MeteoSuisse"
  exit
end

CITY_NAME = location[:name]
LOCATION_ID = location[:id]
METEO_SUISSE_URL = location[:url]
DATA_VERSIONS_IDS = "https://www.meteosuisse.admin.ch/product/output/versions.json"
versions_ids = JSON.parse(URI.open(DATA_VERSIONS_IDS).read)

# MeteoSuisse stopped updating `weather-widget/forecast-v2` and `forecast-chart-v2`;
# the local forecast page now reads from `versioned/localforecast/v1`.
LOCAL_FORECAST_BASE_URL = "https://www.meteosuisse.admin.ch/product/output/versioned/localforecast/v1/version__#{versions_ids['versioned/localforecast/v1']}/fr"
DATA_WEEK = "#{LOCAL_FORECAST_BASE_URL}/days/#{LOCATION_ID}.json"
DATA_DETAILED_FORECAST = "#{LOCAL_FORECAST_BASE_URL}/series/#{LOCATION_ID}.json"

STATIC_IMAGES_URL = "https://www.meteosuisse.admin.ch/static/resources/weather-symbols"

forecasts = JSON.parse(URI.open(DATA_WEEK).read)['days']

data_detailed_forcast_json = JSON.parse(URI.open(DATA_DETAILED_FORECAST).read)
data_today = data_detailed_forcast_json.first
data_tomorrow = data_detailed_forcast_json[1]
symbols_today_and_tomorrow = (data_today['symbols'] + data_tomorrow['symbols']).sort_by { |symbol| symbol['timestamp'] }
symbol_now = symbols_today_and_tomorrow.find { |symbol| Time.at(symbol['timestamp']/1000) >= Time.now }
symbol_next_hour = symbols_today_and_tomorrow.find { |symbol| Time.at(symbol['timestamp']/1000) >= Time.now + 3600}

def get_weather_icon(weather_symbol_id)
  download = URI.open("#{STATIC_IMAGES_URL}/#{weather_symbol_id}.svg")

  Base64.strict_encode64(download.read)
end

next_hour_index = (DateTime.now.hour + 1) % 24 # 0..23
next_hour_data = next_hour_index.zero? ? data_tomorrow : data_today

# Widget display
puts "#{data_today['temperature'][DateTime.now.hour][1]}°C"
puts "---"
puts "Météo à #{CITY_NAME} | href=#{METEO_SUISSE_URL}"
puts " | image=#{get_weather_icon(symbol_now['weather_symbol_id'])} href=#{METEO_SUISSE_URL}"
puts "Température : #{data_today['temperature'][DateTime.now.hour][1]}°C | href=#{METEO_SUISSE_URL}"
puts "Pluie : #{data_today['rainfall'][DateTime.now.hour][1]}mm | href=#{METEO_SUISSE_URL}"
puts "Vitesse du vent : #{data_today['wind']['data'][DateTime.now.hour][1]}km/h | href=#{METEO_SUISSE_URL}"
puts "Direction du vent : #{data_today['wind']['symbols'][0]["symbol_id"]} | href=#{METEO_SUISSE_URL}"
puts "Rafales de vent : #{data_today['wind_gust_peak']['data'][DateTime.now.hour][1]}km/h | href=#{METEO_SUISSE_URL}"
puts "---"
puts "Dans une heure"
puts "--  | href=#{METEO_SUISSE_URL} image=#{get_weather_icon(symbol_next_hour['weather_symbol_id'])}"
puts "-- Température : #{next_hour_data['temperature'][next_hour_index][1]}°C | href=#{METEO_SUISSE_URL}"
puts "-- Pluie : #{next_hour_data['rainfall'][next_hour_index][1]}mm | href=#{METEO_SUISSE_URL}"
puts "-- Vitesse du vent : #{next_hour_data['wind']['data'][next_hour_index][1]}km/h | href=#{METEO_SUISSE_URL}"
puts "-- Direction du vent : #{next_hour_data['wind']['symbols'][(next_hour_index/2).floor]["symbol_id"]} | href=#{METEO_SUISSE_URL}"
puts "-- Rafales de vent : #{next_hour_data['wind_gust_peak']['data'][next_hour_index][1]}km/h | href=#{METEO_SUISSE_URL}"
puts "---"
puts "Semaine à venir"
forecasts.each do |forecast|
  puts "-- #{forecast['label']} #{forecast['tmin']}°C - #{forecast['tmax']}°C"
  puts "---- | image=#{get_weather_icon(forecast['symbol']['id'])}"
  puts "---- Pluie : #{forecast['precipitationRange']}"
end
puts "---"
puts "🇨🇭 MeteoSuisse | href=#{METEO_SUISSE_URL}"
