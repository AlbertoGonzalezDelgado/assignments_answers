
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

#Loading the data from the files
seed_stock_file=ARGV[0]
gene_file=ARGV[1]
cross_data_file=ARGV[2]
output=ARGV[3]

# Estos puts están para comprobar que está funcionando
puts "#{seed_stock_file}"
puts "#{gene_file}"
puts "#{cross_data_file}"
puts "#{output}"

stock_data=Stockdatabase.new(seed_stock_file)
gene_data=Gene.load_genes(gene_file)
cross_data_data=Cross_data.load_data(cross_data_file)

# Estos puts están para comprobar que está funcionando
puts "#{stock_data}"
puts "#{gene_data}"
puts "#{cross_data_data}"

# Accessing to grams remaind of each kind of seed and simulating planting 7 grams
puts 'Planting 7 g of seeds'
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


