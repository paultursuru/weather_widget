#!/usr/bin/env ruby

# <xbar.title>Weather Widget</xbar.title>
# <xbar.version>v0.2</xbar.version>
# <xbar.author>Paul Lahana</xbar.author>
# <xbar.author.github>paultursuru</xbar.author.github>
# <xbar.desc>Weather widget for me</xbar.desc>
# <xbar.dependencies>ruby, json</xbar.dependencies>

require 'json'
require 'open-uri'
require 'date'
require 'base64'

METEO_SUISSE_URL = "https://www.meteosuisse.admin.ch/previsions-locales/lausanne/1007.html"
DATA_VERSIONS_IDS = "https://www.meteosuisse.admin.ch/product/output/versions.json"
versions_ids = JSON.parse(URI.open(DATA_VERSIONS_IDS).read)

DATA_WEEK = "https://www.meteosuisse.admin.ch/product/output/weather-widget/forecast-v2/version__#{versions_ids['weather-widget/forecast-v2']}/fr/100700.json"
DATA_DETAILED_FORECAST = "https://www.meteosuisse.admin.ch/product/output/forecast-chart-v2/version__#{versions_ids['forecast-chart-v2']}/fr/100700.json"

STATIC_IMAGES_URL = "https://www.meteosuisse.admin.ch/static/resources/weather-symbols"

data_week_json = JSON.parse(URI.open(DATA_WEEK).read)
data = data_week_json['data']
forecasts = data['forecasts']

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

next_hour_index = DateTime.now.hour % 24 # 0..23
next_hour_data = next_hour_index.zero? ? data_tomorrow : data_today

# Widget display
puts "#{data_today['temperature'][DateTime.now.hour][1]}°C"
puts "---"
puts "Météo à #{data['city_name']} | href=#{METEO_SUISSE_URL}"
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
  puts "-- #{forecast['weekday']} #{forecast['temp_low']}°C - #{forecast['temp_high']}°C"
  puts "---- | image=#{get_weather_icon(forecast['weather_symbol_id'])}"
  puts "---- Pluie : #{forecast['precip_mean']}mm - #{forecast['precip_max']}mm"
end
puts "---"
puts "🇨🇭 MeteoSuisse | href=#{METEO_SUISSE_URL}"
