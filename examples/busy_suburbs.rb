load "#{File.dirname(__FILE__)}/../lib/swan_taxis/address.rb"
load "#{File.dirname(__FILE__)}/../lib/swan_taxis/address_ext.rb"

# load reference DB
SwanTaxis::Address.sql_db="#{File.dirname(__FILE__)}/../ref_data/embedded.db"

# prepare query
set = SwanTaxis::Address.streets_dataset
group_query = set.group(:suburb_name)

# convert query into address objects
all_suburbs = SwanTaxis::Address.array_from_dataset(group_query)

# iterate through all suburbs to get busy suburbs
all_suburbs.each { |address| puts address.suburb_name if address.busy? }