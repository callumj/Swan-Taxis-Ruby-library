# SwanTaxis Unofficial Ruby API (beta-alpha-delta) #

This Ruby library is a Saturday attempt at building an unofficial Ruby wrapper around the SwanTaxis iPhone API used on their iOS clients. It aims to replicate most of the features that are made available on the mobile client to allow developers to hack away at interesting projects on the SwanTaxis API.

## Heads up ##

Please be aware that this is an unofficial API, it has been developed by sticking a debugging proxy and logging requests made by the iOS client and building wrappers around each of service endpoints. This client is not sanctioned by SwanTaxis and should not be abused, it is meant for playful hacking where a user may actually need a taxi delivered to their required address; please do not use this API to cause stress to the SwanTaxis dispatching system.


## Location info ##

This repo also includes the location data SwanTaxis used to send streets, street types and suburbs to the server. It is provided in CSV format and it best stored in a lightweight database for quick resolving of a desired street. You will need this information to be able to specify locations for picking up and dropping off, for reference "Designation" refers to the street type.

The Streets.txt file provides the format dbkey,STREETID,streetname,STREETTYPEID,suburbname,SUBURBID where you will need STREETID, STREETTYPEID and SUBURBID when constructing a SwanTaxis::Address object for setting the to\_address and from\_address in a SwanTaxis::Booking object.

## Requirements ##

Rest-client (https://github.com/archiloque/rest-client) or just run bundle

## Usage ##

Here is a way to register a new user on the SwanTaxi web service. Please use real user data, it would be unfair to prank the system. Also the system currently on accepts alphabet characters in the username field.

	user = SwanTaxis::User.register({:username => "mikeperth", :password => "password", :firstname => "Joe", :lastname => "Citizen", :phone_number => "0407028504", :email => "mike@me.com"})

This will return a user object, if you need to login later.

	user =  SwanTaxis::User.login("mikeperth", "password")
	
Now you can make a booking. In this case I am using 1 Adina Road, City Beach as my pickup address and using 20 St Georges Terrace, Perth as my dropoff due tomorrow night.

	f = SwanTaxis::Address.new
	f.house_number = 1
	f.street_id = 120
	f.street_type_id = 87
	f.suburb_id = 76
	
	t = SwanTaxis::Address.new
	t.house_number = 20
	t.street_id = 14567
	t.street_type_id = 109
	t.suburb_id = 300
	
	b = SwanTaxis::Booking.new
	b.to_address = t
	b.from_address = f
	b.date = (Time.now + (60 * 60 * 24))
	b.number_people = 4
	b.user = user
	
	#How much will it cost?
	b.charge_estimate
	
	#Ok book
	b.book
	
	#How's it going?
	b.status
	b.location
	
	#My bad
	b.cancel_booking