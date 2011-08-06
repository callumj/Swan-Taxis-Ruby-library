require 'rest-client'
require 'json'

module SwanTaxis
  class Base
    @@URI = "http://iphone.swantaxis.com.au:5005"
    attr_accessor :fields
    
    def initialize
      self.fields = {}
    end
    
    #Pass arguments to the web service and then coerce them back into the class data
    def coerce(args = {})      
      return nil unless args[:endpoint] != nil && args[:params] != nil
            
      response = Base.perform_request(args)

      if (response != nil)
        resp_json = JSON.parse(response)
        resp_json = resp_json.inject({}){|target,(k,v)| target[k.to_sym] = v; target}
        if (resp_json != nil)
          self.fields.merge!(resp_json)
        end
      end
    end
    
    #Generic Web service accessor
    def Base.perform_request(args = {})
      return nil unless args[:endpoint] != nil && args[:params] != nil
      
      path = "SwanTaxisService.svc"
      path = "SwanTaxisBookingService.svc" if args[:booking_svc]
      
      RestClient.post "#{@@URI}/#{path}/#{args[:endpoint]}", args[:params].to_json, :content_type => :json, :accept => :json
    end
  end
end