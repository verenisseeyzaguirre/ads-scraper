require_relative "scraper_all_ads_service"
require_relative "realestate"
require 'json'

class Controller
  def initialize(id)
    @realestate = Realestate.new(id)
  end

  def run
    ads = ScraperAllAdsService.new(@realestate.id).call
    if ads.nil?
      puts "Argumento ingresado no válido"
      return
    end
    @realestate.set_ads(ads)
    catalog_json = @realestate.to_json
    ads_count = catalog_json.size
    if ads_count == 0
      puts "No hay anuncios"
    elsif ads_count == 1
      puts "Guardando 1 anuncio..."
    else
      puts "Guardando #{ads_count} anuncios..."
    end
    File.write("./output/#{@realestate.id}.json", JSON.pretty_generate(catalog_json))
    puts "Archivo #{@realestate.id}.json creado"
  end
end
