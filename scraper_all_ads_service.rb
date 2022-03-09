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
    base_url_dollar = 'https://cuantoestaeldolar.pe/'
    html = URI.open("#{base_url_dollar}").read
    doc = Nokogiri::HTML(html, nil, "utf-8")
    value = doc.xpath('/html/body/div[3]/section/div[1]/div[3]/div/div[1]/div/div/div[3]/div[2]').attribute("data-compra").value.to_f
    # @dollar_result = value
  end

  def scraping_ads_per_page(html_per_page)
    dollar_value = 3.73
    doc_per_page = Nokogiri::HTML(html_per_page, nil, 'utf-8')
    doc_per_page.search('.vivienda-item').each do |element|
      title = element.search('.flash').first.attribute('alt').value.strip
      property_href = element.search('.title a').first.attribute('href').value.strip
      base_url = 'https://www.laencontre.com.pe'
      property_url = base_url + property_href
      property_html = URI.open(property_url).read
      id = property_href.split('/')[2]
      property_doc = Nokogiri::HTML(property_html, nil, 'utf-8')
      # Para el reto se captura sólo las primeras 3 fotos de querer todo retira '.first(3)'
      original_pictures = property_doc.css('.mfp-gallery').first(3).map do |element|
        element['href']
      end

      location_data = property_doc.search('.elementBC.detail-bread-li').map(&:text)
      region = location_data[2].strip
      province = location_data[3].strip
      district = location_data[4].strip

      property_description =  property_doc.search('.description').text != '' ? property_doc.search('.description').text : ''
      head_title = property_doc.search('title').text != '' ? property_doc.search('title').text.split(' ') : ''
      address = property_doc.search('.location h2').text != '' ? property_doc.search('.location h2').text : ''

      property_type = {
        'name': head_title[1].capitalize,
        'slug': head_title[1].downcase
      }
      operation_type = {
        'name': head_title[0].capitalize,
        'slug': head_title[0].downcase
      }

      specifications = property_doc.search('.priceChars')
      price_dollars = specifications.search('.price h2').text != '' ? specifications.search('.price h2').text.split('$')[1].strip.tr(',', '').to_f : 0

      details_list = specifications.search('.details_list')
      dimensions = details_list.search('.dimensions').text != '' ? details_list.search('.dimensions').text.split('m2')[0].to_i : 0

      bedrooms = details_list.search('.bedrooms').text
      bedrooms_value = bedrooms.tr('m2', '').to_i

      bathrooms = details_list.search('.bathrooms').text != '' ? details_list.search('.bathrooms').text.split('Baño')[0].split('-')[0].to_i : 0

      geolocation = property_doc.search('#see-map')
      geo_point = {
        'lat': geolocation.attribute('data-x').value.to_f,
        'lon': geolocation.attribute('data-y').value.to_f
      }

      @catalog << Ad.new(
        id: "LE-'#{id}",
        title: title,
        original_url: property_url,
        original_pictures: original_pictures,
        description: property_description,
        property_type: property_type,
        operation_type: operation_type,
        usd_price: price_dollars,
        local_price: (price_dollars * dollar_value).round(2),
        total_area: dimensions,
        build_area: dimensions,
        bedrooms: bedrooms_value,
        bathrooms: bathrooms,
        garages: nil,
        years_old: nil,
        location: {
          address: address,
          country: 'Peru',
          region: region,
          province: province,
          district: district,
          zone: '',
          geo_point: geo_point,
          country_slug: 'peru',
          region_slug: region.downcase,
          province_slug: province.downcase,
          district_slug: district.downcase,
          zone_slug: ''
        }
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
    puts 'Buscando...'
    begin
      URI.open(@url_realestate_id).read
    rescue OpenURI::HTTPError
      return
    end
    url_rentals = "#{@url_realestate_id}/alquiler/propiedades"
    url_sales = "#{@url_realestate_id}/venta/propiedades"
    puts 'Scraping...'
    pages_per_operation_results(url_rentals)
    pages_per_operation_results(url_sales)
    @catalog
  end
end
