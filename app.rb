require "sinatra"
require "sinatra/reloader"
require "geocoder"
require "forecast_io"
require "httparty"
def view(template); erb template.to_sym; end
before { puts "Parameters: #{params}" }                                     

# enter your Dark Sky API key here
ForecastIO.api_key = "8e1b330346ab4d1552b64cb18e04a801"
url = "https://newsapi.org/v2/top-headlines?country=us&apiKey=a64ee39ed7044afbb2ceb662b3140707"
news = HTTParty.get(url).parsed_response.to_hash

get "/" do
  view "ask"
end

get "/news" do 
    results = Geocoder.search(params["location"])
    lat_long = results.first.coordinates

    @forecast = ForecastIO.forecast(lat_long[0],lat_long[1]).to_hash
    @current_temperature = @forecast["currently"]["temperature"]
    @current_summary = @forecast["currently"]["summary"]

    @forecast_temperature = Array.new
    @forecast_summary = Array.new
    @forecast_time = Array.new
    i = 0
    
    for day in @forecast["daily"]["data"] do
        @forecast_time[i] = day["time"]
        @forecast_temperature[i] = day["temperatureHigh"]
        @forecast_summary[i] = day["summary"]
        i = i+1
    end

    @title = Array.new
    @story_link = Array.new
    a = 0
    for story in news["articles"] do
        @title[a] = story["title"]
        @story_link[a] = story["url"]
        a = a+1
    end

    view "news"

end