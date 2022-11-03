
# Importing required classes ("path to classes")
require './class_cross_data.rb'
require './class_seed_stock.rb'
require './class_genes.rb'

require 'csv'

# https://stackoverflow.com/questions/28488422/how-to-check-the-number-of-arguments-passed-with-a-ruby-script 
# How to access to arguments in ruby

#Checking if the arguments required are specified 
unless ARGV.length == 4 then # Paths to classes are required as arguments?
    abort("FATAL ERROR: Files pathways are required. Check README.md for more information.")
end

#Loading the data from the files
seed_stock_file= ARGV[0]
gene_file=ARGV[1]
cross_data_file=ARGV[2]
output=ARGV[3]

puts ''
# Estos puts están para comprobar que está funcionando
#puts 'file paths'
#puts "#{seed_stock_file}"
#puts "#{gene_file}"
#puts "#{cross_data_file}"
#puts "#{output}"

stock_data=Stockdb.new_database(seed_stock_file, output)
gene_data=Genes.load_genes(filepath: gene_file)
cross_data_data=Cross_data.load_data(filepath: cross_data_file)

# Estos puts están para comprobar que está funcionando
#puts 'files info'
#puts 'seed_Stock'
#puts "#{stock_data}"
puts ''
#puts 'gene'
puts ''
#puts "#{gene_data}"
#puts 'cross_data'
#puts "#{cross_data_data}"

# Accessing to grams remaind of each kind of seed and simulating planting 7 grams
sleep 1
puts 'Planting 7 g of seeds'
sleep 1
puts '...'
sleep 1
puts '...'
sleep 1
puts ''
puts 'Seeds have been planted. The current status of genebank is:'
puts "#{CSV.parse(File.open(output), headers: true)}" # The output is a table where the grams of seed remains and the last date of plant is contained
sleep 1
puts ''
sleep 1
puts ''

#Obtaining genes from seeds plainted
sleep 1
puts ''
puts ''

# Calculating chisquared
puts 'Now the genes that are linked will be calculated'
puts '...'
puts 'cositas que pocos saben'


