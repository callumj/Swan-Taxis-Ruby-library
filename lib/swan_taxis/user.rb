load "#{File.dirname(__FILE__)}/base.rb"

require 'json'

module SwanTaxis
  class User < Base
    
    #User attrs
    def user_id
      self.fields[:Id]
    end
    
    def user_name
      self.fields[:UserName]
    end
    
    def first_name
      self.fields[:FirstName]
    end
    
    def last_name
      self.fields[:LastName]
    end
    
    def email
      self.fields[:Email]
    end
    
    def phone_number
      self.fields[:Phone]
    end
    
    
    #Sadly this has to be sent in plain text
    def self.login(username, password)
      user_build = User.new
      user_build.coerce :endpoint => "Login", :booking_svc => false, :params => {:user => {:Password => password, :UserName => username}}
      
      user_build
    end
    
    #Once again plain text
    def self.register(args = {})
      resp = self.class.perform_request(:endpoint => "RegisterUser", :booking_svc => false,
        :params => {
            :user => {
              :Password => args[:password], 
              :UserName => args[:username], 
              :FirstName => args[:firstname],
              :LastName => args[:lastname],
              :Phone => args[:phone_number],
              :Email => args[:email]
            }
          })
          
      resp_json = JSON.parse(resp)
      return User.login(args[:username], args[:password]) if (resp_json != nil && resp_json["Id"] > 0)
      
      return nil
    end
  end
end