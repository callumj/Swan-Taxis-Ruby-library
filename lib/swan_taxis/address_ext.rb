# This extends Address' ability to look up suburbs/streets against the embedded SQL db
# This separation has been chosen so people can choose to have the lightweight Address class and use their own method of looking up the DB values.

require 'sequel'
require 'sqlite3'

module SwanTaxis
	class Address
		#This fields exist purely for sanity checking
		attr_accessor :street_name
		attr_accessor :suburb_name
		attr_accessor :street_type
		
		#Store DB ref
		@@SQL_INSTANCE = nil
		
		def self.sql_db=(file_path)
			@@SQL_INSTANCE = Sequel.sqlite(file_path)
		end
		
		def self.one(args = {})
			return if @@SQL_INSTANCE == nil
			
			find = @@SQL_INSTANCE[:streets].where(args).first
			return self.from_db_hash(find) if (find != nil)
			
			nil
		end
		
		def self.all(args = {})
			return if @@SQL_INSTANCE == nil
			
			self.array_from_dataset(self.streets_dataset)
		end
		
		def self.array_from_dataset(dataset)
			return if dataset == nil || @@SQL_INSTANCE == nil
			
			results = []
			find = dataset.all
			find.each {|record| results << self.from_db_hash(record) }
			
			results
		end
		
		def self.streets_dataset
			return if @@SQL_INSTANCE == nil
			
			@@SQL_INSTANCE[:streets]
		end
		
		#Provide handy way to cast DB into class
		private
		def self.from_db_hash(args = {})
			creation = Address.new
			creation.street_id = args[:street_id]
			creation.street_type_id = args[:street_type_id]
			creation.suburb_id = args[:suburb_id]
			
			#be verbose
			creation.street_name = args[:street_name]
			creation.street_type = args[:street_type]
			creation.suburb_name = args[:suburb_name]
			
			creation
		end
	end
end