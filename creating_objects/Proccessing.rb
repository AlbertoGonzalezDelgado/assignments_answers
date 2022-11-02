
# Importing required classes ("path to classes")
require './class_cross_data.rb'
require './class_seed_stock.rb'
require './class_genes.rb'

# https://stackoverflow.com/questions/28488422/how-to-check-the-number-of-arguments-passed-with-a-ruby-script 
# How to access to arguments in ruby

#Checking if the arguments required are specified 
if ARGV.length != 4 then # Paths to classes are required as arguments?
    abort("Files pathways are required")
end

seed_stock_file=ARGV[0]
gene_file=ARGV[1]
cross_data_file=ARGV[2]
output=ARGV[3]


# Accessing to grams remaind of each kind of seed and simulating planting 7 grams
puts 'Planting 7 g of seeds'
stock=Cross_data.new(cross_data_file)
sleep 1
puts '...'
sleep 1
puts '...'
puts "stock.new_database(#{ARGV[3]})" # The output is a table where the grams of seed remains and the last date of plant is contained
puts ''
puts ''

#Obtaining genes from seeds plainted
puts 'The genes planted are:'
puts "#{ARGV[3]}["Gene_ID"]"
puts ''
puts ''
puts ''

# Calculating chisquared


