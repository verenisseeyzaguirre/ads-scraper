class Ad
    attr_reader :id, :title, :original_url, :original_pictures, :description, :property_type, :operation_type, :usd_price, :local_price, :total_area, :build_area, :bedrooms, :bathrooms, :garages, :years_old, :location
  
    def initialize(attributes = {})
        @id = attributes[:id]
        @title = attributes[:title]
        @original_url = attributes[:original_url]
        @original_pictures = attributes[:original_pictures]
        @description = attributes[:description]
        @property_type = attributes[:property_type]
        @operation_type = attributes[:operation_type]
        @usd_price = attributes[:usd_price]
        @local_price = attributes[:local_price]
        @total_area = attributes[:total_area]
        @build_area = attributes[:build_area]
        @bedrooms = attributes[:bedrooms]
        @bathrooms = attributes[:bathrooms]
        @garages = attributes[:garages]
        @years_old = attributes[:years_old]
        @location = attributes[:location]
    end


    def to_json
        {
            "id": @id,
            "title": @title,
            "original_url": @original_url,
            "original_pictures": @original_pictures,
            "description": @description,
            "property_type": @property_type,
            "operation_type": @operation_type,
            "usd_price": @usd_price,
            "local_price": @local_price,
            "total_area": @total_area,
            "build_area": @build_area,
            "bedrooms": @bedrooms,
            "bathrooms": @bathrooms,
            "garages": @garages,
            "years_old": @years_old,
            "location": @location
        }
    end
end
  
