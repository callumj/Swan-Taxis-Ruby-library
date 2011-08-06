load "#{File.dirname(__FILE__)}/base.rb"
load "#{File.dirname(__FILE__)}/user.rb"
load "#{File.dirname(__FILE__)}/address.rb"

require 'json'

module SwanTaxis
  class Booking < Base
    
    def initialize
      super
    end
    
    #user
    def user=(val)
      self.fields[:UserId] = val.user_id
    end
    
    #address    
    def to_address=(val)
      self.fields[:toAddress] = {:Number => val.house_number, :StreetId => val.street_id, :DesignationId => val.street_type_id, :SuburbId => val.suburb_id}
    end
    
    def from_address=(val)
      self.fields[:fromAddress] = {:Number => val.house_number, :StreetId => val.street_id, :DesignationId => val.street_type_id, :SuburbId => val.suburb_id}
    end
    
    #date
    def date=(date)
      self.fields[:RequestedDate] = "#{date.strftime("%Y%m%d%H%M%S")}"
    end
    
    #booking id, mainly used to set an existing booking
    def id
      self.fields[:BookingId]
    end
    
    def id=(val)
      self.fields[:BookingId] = val
    end
    
    #change the seating type
    def number_people=(count)
      if count <= 4
        self.fields[:fleetId] = 1
      elsif count >= 13
        self.fields[:fleetId] = 13
      elsif count >= 8 && count < 13
        self.fields[:fletId] = count
      elsif count > 4 && count < 8
        case count
          when 5
            self.fields[:fleetId] = 3
          when 6
            self.fields[:fleetId] = 5
          when 7 
            self.fields[:fleetId] = 6
        end
      end
    end
    
    def fleet_id=(val)
      self.fields[:fleetId] = val
    end
    
    def fleet_id
      self.fields[:fleetId]
    end
    
    def normalise!
      self.fields[:fleetId] = 1 if self.fields[:fleetId] == nil
      self.fields[:Source] = 2
      self.fields[:Conditions] = 0
    end
    
    def book
      self.normalise!
      booking_req = {:booking => self.fields}
      
      self.coerce :endpoint => "CreateBooking", :booking_svc => true, :params => booking_req
      self.fields.delete(:ErrorDetails)
      self.fields.delete(:ErrorCode)
    end
    
    def status
      resp = self.class.perform_request(:endpoint => "GetBookingStatus", :booking_svc => true, :params => {:BookingId => self.id})
      
      if (resp != nil)
        resp_json = JSON.parse(resp)
        if (resp_json != nil)
          resp_json = resp_json[0] if resp_json.class == Array
          return resp_json["Status"] 
        end
      end
      
      nil
    end
    
    def cancel_booking
      resp = self.class.perform_request(:endpoint => "CancelBooking", :booking_svc => true, :params => {:bookingId => self.id})
      
      if (resp != nil)

        resp_json = JSON.parse(resp)
        if (resp_json != nil)
          resp_json = resp_json[0] if resp_json.class == Array
          return resp_json["ErrorCode"] == 0
        end
      end
      
      false
    end
    
    def location
      resp = self.class.perform_request(:endpoint => "GetTaxiPositionForBooking", :booking_svc => true, :params => {:BookingId => self.id})
      
      if (resp != nil)
        resp_json = JSON.parse(resp)
        if (resp_json != nil)
          resp_json = resp_json[0] if resp_json.class == Array
          return {:lat => resp_json["Lat"], :long => resp_json["Long"]} if resp_json["ErrorCode"] == 0
        end
      end
      
      nil
    end
    
    def charge_estimate
      self.normalise!
      booking_req = {:booking => self.fields}  
      resp = self.class.perform_request(:endpoint => "ChargeEstimate", :booking_svc => true, :params => booking_req)
      
      if (resp != nil)
        resp_json = JSON.parse(resp)
        if (resp_json != nil)
          resp_json = resp_json[0] if resp_json.class == Array
          return {:including_tolls => resp_json["ChargeExcludingTolls"], :excluding_tolls => resp_json["ChargeExcludingTolls"]} if resp_json["ErrorCode"] == 0
        end
      end
      
      nil
    end
  end
end