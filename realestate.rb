class Realestate
    attr_reader :id, :ads
  
    def initialize(realestate_id)
      @id = realestate_id
      @ads = []
    end

    def set_ads(ads)
        @ads = ads
    end

    def to_json
        results = []
        @ads.each do |ad| 
            results << ad.to_json
        end
        results
    end
end

