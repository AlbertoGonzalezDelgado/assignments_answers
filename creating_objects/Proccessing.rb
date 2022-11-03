
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
stock=Stockdatabase.new(seed_stock_file)
sleep 1
puts '...'
sleep 1
puts '...'
sleep 1
puts ''
puts 'Seeds have been planted. The current status of genebank is:'
puts "#{stock}" # The output is a table where the grams of seed remains and the last date of plant is contained
sleep 1
puts ''
puts ''

#Obtaining genes from seeds plainted
puts 'The genes planted are:'
Gene_ID_planted=stock.get["Mutant_Gene_ID"] #Saving the Gene IDs of seed planted
puts "#{stock.get["Mutant_Gene_ID"]}"
sleep 1
puts ''
puts ''

# Calculating chisquared
puts 'Now the genes that are linked will be calculated'
puts '...'


