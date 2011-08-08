load "#{File.dirname(__FILE__)}/base.rb"

require 'json'

module SwanTaxis
  class Address
   attr_accessor :house_number
   attr_accessor :street_id
   attr_accessor :street_type_id
   attr_accessor :suburb_id
   
   def busy?
		return false if self.suburb_id == nil
		
		resp = Base.perform_request(:endpoint => "IsBusy", :booking_svc => true, :params => {:suburbId => self.suburb_id})
		
		if (resp != nil)
			resp_json = JSON.parse(resp)
			if (resp_json != nil)
				resp_json = resp_json[0] if resp_json.class == Array
				return resp_json["IsBusy"] > 0 if resp_json["ErrorCode"] == 0
			end
		end
		
		false
	 end
	 
  end
end