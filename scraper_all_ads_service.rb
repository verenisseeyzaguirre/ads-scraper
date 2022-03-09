require 'open-uri'
require 'nokogiri'
require_relative 'ad'

class ScraperAllAdsService
  def initialize(realestate_id)
    @realestate_id = realestate_id
    @url_realestate_id = "https://www.laencontre.com.pe/agente/x-#{realestate_id}"
    @catalog = []
  end

  def dollar_value
    base_url_dollar = "https://cuantoestaeldolar.pe/"
    html = URI.open("#{base_url_dollar}").read
    doc = Nokogiri::HTML(html, nil, "utf-8")
    value = doc.xpath('/html/body/div[3]/section/div[1]/div[3]/div/div[1]/div/div/div[3]/div[2]').attribute("data-compra").value.to_f
  end

  def scraping_ads_per_page(html_per_page)
    dollar_result = dollar_value()

    doc_per_page = Nokogiri::HTML(html_per_page, nil, 'utf-8')

    doc_per_page.search('.vivienda-item').each do |element|
      title = element.search('.flash').first.attribute('alt').value.strip
      property_href = element.search('.title a').first.attribute('href').value.strip
      base_url = "https://www.laencontre.com.pe"
      property_url = base_url + property_href
      property_html = URI.open(property_url).read
      id = property_href.split('/')[2]

      # property details
      property_doc = Nokogiri::HTML(property_html, nil, 'utf-8')
      #original_pictures = property_doc.css('.mfp-gallery').map do |element|
      #  element['href']
      #end

      property_description = property_doc.search('.description').text

      firstLine = property_doc.search('#firstLine h1').text
      info = firstLine.split(' ')

      property_type = {
        'name':info[0],
        'slug':info[0].downcase
      }
      operation_type = {
        'name':info[2],
        'slug':info[2].downcase
      }

      caracteristicas = property_doc.search('.priceChars')
      price_sc = caracteristicas.search('.price h2').text
      #p price_sc
      price = price_sc.split(' ')[1].tr(',','').to_i

      masdatos = caracteristicas.search('.details_list')
      dimensions = masdatos.search('.dimensions').text
      # p dimensions

      bedrooms = masdatos.search('.bedrooms').text
      bedrooms_value = bedrooms.tr('m2','').to_i

      bathrooms = masdatos.search('.bathrooms').text
      # p bathrooms

      geolocation = property_doc.search('#see-map')
      geo_point = {
        'lat': geolocation.attribute('data-x').value.to_f,
        'lon': geolocation.attribute('data-y').value.to_f
      }
      # p geo_point

      @catalog << Ad.new(
        id: 'LE-' + id,
        title: title,
        original_url: property_url,
        original_pictures: '',
        description: property_description,
        property_type: property_type,
        operation_type: operation_type,
        usd_price: price,
        local_price: (price*dollar_result).round(2),
        total_area: 0,
        build_area: 0,
        bedrooms: bedrooms_value,
        bathrooms: bathrooms,
        garages: nil,
        years_old: nil,
        location: {
          address: '',
          country: '',
          region: '',
          province: '',
          district: '',
          zone: '',
          geo_point: geo_point,
          country_slug: '',
          region_slug: '',
          province_slug: '',
          district_slug: '',
          zone_slug: ''
        },
      )
    end
  end

  def pages_per_operation_results(url_operation_type)

    html_operation_type = URI.open(url_operation_type).read

    # 1. Parse HTML
    doc_operation_type = Nokogiri::HTML(html_operation_type, nil, 'utf-8')
    # 2. For all results
    get_pages = doc_operation_type.search('.pagination').length
    total_page_number = get_pages == 0 ? 1 : doc_operation_type.search('.pagination').first.attributes['data-tp'].value.to_i
    page_number = 1
    total_page_number.times do
      url_operation_type_page = "#{url_operation_type}/p_#{page_number}"
      page_number += 1
      html_operation_type_page = URI.open(url_operation_type_page).read
      scraping_ads_per_page(html_operation_type_page)
    end
  end

  def call
    puts "Buscando..." 
    begin
      html = URI.open(@url_realestate_id).read
    rescue OpenURI::HTTPError
      return
    end 
    url_rentals = "#{@url_realestate_id}/alquiler/propiedades"
    url_sales = "#{@url_realestate_id}/venta/propiedades"
    puts "Scraping..."
    pages_per_operation_results(url_rentals)
    pages_per_operation_results(url_sales)
    @catalog
  end
end
