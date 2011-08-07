# SwanTaxis Unofficial Ruby API (beta-alpha-delta) #

This Ruby library is a Saturday attempt at building an unofficial Ruby wrapper around the SwanTaxis iPhone API used on their iOS clients. It aims to replicate most of the features that are made available on the mobile client to allow developers to hack away at interesting projects on the SwanTaxis API.

## Heads up ##

Please be aware that this is an unofficial API, it has been developed by sticking a debugging proxy and logging requests made by the iOS client and building wrappers around each of service endpoints. This client is not sanctioned by SwanTaxis and should not be abused, it is meant for playful hacking where a user may actually need a taxi delivered to their required address; please do not use this API to cause stress to the SwanTaxis dispatching system.


## Location info ##

This repo also includes the location data SwanTaxis used to send streets, street types and suburbs to the server. It is provided in CSV format and it best stored in a lightweight database for quick resolving of a desired street. You will need this information to be able to specify locations for picking up and dropping off, for reference "Designation" refers to the street type.

The Streets.txt file provides the format dbkey,STREETID,streetname,STREETTYPEID,suburbname,SUBURBID where you will need STREETID, STREETTYPEID and SUBURBID when constructing a SwanTaxis::Address object for setting the to\_address and from\_address in a SwanTaxis::Booking object.

### Using the Address extension for searching the embedded db ###

This repo now ships with a sqlite db that contains the Streets data, this now allows an extension to the SwanTaxis::Address class to query this database to make looking up street data easier. As a design decision these extensions are in a separate class called address_ext.rb to give developers the choice of using their own db implementation.

The address extension class then exposes three helpful methods.

	load 'lib/swan_taxis/address_ext.rb'
	
	# Need to specify where our database lives (this enables the Sequel + SQLite engine)
	SwanTaxis::Address.sql_db= "ref_data/embedded.db"
	
	home = SwanTaxis::Address.one(:street_name => "Taworri", :street_type => "Way", :suburb_name => "City Beach")
	home.house_number = 1 

## Requirements ##

Rest-client (https://github.com/archiloque/rest-client)
Sequel
Sqlite3

(just run _bundle_, as this is declared in the Gemfile)

## Usage ##

Here is a way to register a new user on the SwanTaxi web service. Please use real user data, it would be unfair to prank the system. Also the system currently on accepts alphabet characters in the username field.

	user = SwanTaxis::User.register({:username => "mikeperth", :password => "password", :firstname => "Joe", :lastname => "Citizen", :phone_number => "0407028504", :email => "mike@me.com"})

This will return a user object, if you need to login later.

	user =  SwanTaxis::User.login("mikeperth", "password")
	
Now you can make a booking. In this case I am using 1 Adina Road, City Beach as my pickup address and using 20 St Georges Terrace, Perth as my dropoff for tomorrow night.
	
	load 'lib/swan_taxis/booking.rb'
	load 'lib/swan_taxis/address_ext.rb' # We wish to enable the ability to do lookup street data easily
	
	SwanTaxis::Address.sql_db= "ref_data/embedded.db" # Use the provided DB
	
	f = SwanTaxis::Address.one(:street_name => "Adina", :street_type => "Rd", :suburb_name => "City Beach")
	f.house_number = 1
	
	t = SwanTaxis::Address.one(:street_name => "St Georges", :street_type => "Tce", :suburb_name => "Perth")
	t.house_number = 20
	
	b = SwanTaxis::Booking.new
	b.to_address = t
	b.from_address = f
	b.date = (Time.now + (60 * 60 * 24))
	b.number_people = 4
	
	b.user = user
	
	# How much will it cost?
	b.charge_estimate
	
	# Ok book
	b.book
	
	# How's it going?
	b.status
	b.location
	
	# My bad
	b.cancel_booking
	
## License ##

This code is licensed through the MIT license, so please do what ever you want with the source. If you do make any modifications it would be great if you could make this public on somewhere like Github for other people to benefit. Open source software has helped me a lot and it would be unfair of me to strap some prohibitive license on such basic functionality.