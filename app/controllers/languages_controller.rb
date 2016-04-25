require 'net/http'
require 'byebug'
class LanguagesController < ApplicationController

  # GET /languages
  # GET /languages.json
  def index
    if Language.count == 0
      url = URI.parse("https://www.googleapis.com/language/translate/v2/languages?target=en&key=#{ENV.fetch('KEY')}")
      req = Net::HTTP::Get.new(url.request_uri)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == "https")
      response = http.request(req)
      response = (JSON.parse(response.body)).deep_symbolize_keys
      response = response[:data]
      response = response[:languages]
      response.each do |language|
        Language.create(language: language[:language], name: language[:name])
      end
    end
    @languages = Language.all
  end

  def translate
    input = params["input"]
    input = input.tr(" ", "+")
    language = params["language"]
    language1 = language["language1"]
    language2 = language["language2"]
    url = URI.parse("https://www.googleapis.com/language/translate/v2?q=#{input}&target=#{language2}&source=#{language1}&key=#{ENV.fetch('KEY')}")
    req = Net::HTTP::Get.new(url.request_uri)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == "https")
    response = http.request(req)
    response = (JSON.parse(response.body)).deep_symbolize_keys
    response = response[:data][:translations]
    $output = response[0][:translatedText]
    redirect_to "/"
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_language
      @language = Language.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def language_params
      params.require(:language).permit(:language, :name)
    end
end
