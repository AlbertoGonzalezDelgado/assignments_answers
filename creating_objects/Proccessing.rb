
# Importing required classes ("path to classes")
require './class_cross_data.rb'
require './class_seed_stock.rb'
require './class_genes.rb'

#Checking if the arguments required are specified 
unless ARGV.length == 4 then # Paths to classes are required as arguments?
    abort("FATAL ERROR: Files pathways are required. Check README.md for more information.")
end

#Checking if the files specified exist and aborting the program if does not.
ARGV[0..2].each do |arg|
    unless File.file?(arg)
       abort("FATAL ERROR: File #{arg} doesn't exist")
    end
end

if File.file?(ARGV[3])
    puts "#{ARGV[3]} already exists, indicate if you want to overwrite [Y/N]" 
    overwrite=STDIN.gets.strip
    if overwrite==("N"||"n")
        abort("Run cancelled")
    end
end

#Asking for amount of seeds to plant
puts "Indicate the amount of seeds (g):"
seeds=STDIN.gets.strip

#Loading the data from the files
seed_stock_file= ARGV[0]
gene_file= ARGV[1]
cross_data_file=ARGV[2]
output=ARGV[3]

sleep 1
puts "Planting #{seeds} g of seeds"
sleep 1
puts '...'
sleep 1
puts '...'
sleep 1
puts ''
puts ''
stock_data=Stockdb.new_database(stockpath: seed_stock_file, newdb: output, seeds: seeds)
sleep 1
gene_data=Genes.load_genes(filepath: gene_file)
cross_data_data=Cross_data.load_data(filepath: cross_data_file)

puts ''
puts ''


# Accessing to grams remaind of each kind of seed and simulating planting 7 grams
puts 'Seeds have been planted. The current status of genebank is:'
puts "#{CSV.parse(File.open(output), headers: true)}" # The output is a table where the grams of seed remains and the last date of plant is contained
sleep 1
puts ''
sleep 1

#Obtaining genes from seeds plainted
sleep 1
puts ''
puts ''
sleep 1

# Calculating linked genes and chi square
puts 'Now the genes that are linked will be calculated'
puts '...'
sleep 1
puts 'cositas que pocos saben'
sleep 1
puts '...'
sleep 1

## We get the crosses that provide results of linked genes.
linked_cross, chi_sq = Cross_data.get_linked(filepath: cross_data_file)

## We retrieve the Seed Stock objects involved in the cross
linked_seeds = Stockdb.load_file(stockpath: seed_stock_file).select {|seed| seed.seed_stock == linked_cross.parent1 || \
                                                                      seed.seed_stock == linked_cross.parent2}

## Finally, we retrieve the genes filtering by their ids, and we return the gene names

linked_genes = []
linked_seeds.each do |seed| 
    linked_gene = gene_data.select {|gene| gene.gene_ID == seed.mutant_gene_id}[0]
    linked_genes << linked_gene
end

print "Gene #{linked_genes[0].gene_name} and gene #{linked_genes[1].gene_name} are linked with a Chi square value of #{chi_sq.round(2)} (p < 0.05)"

sleep 1
puts ''
puts ''
sleep 1
puts'⠀⠀⠀⠈⣷⣶⣤⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ '
puts'⠀⠀⠀⠀⣿⣿⠻⣿⣿⣿⣿⣶⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀'
puts'⠀⠀⠀⠀⣿⣿⣧⡈⠻⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣄⡀⠀⠀⠀'
puts'⠀⠀⠀⠀⢿⣿⣿⣿⣦⡈⠙⠿⣿⣿⠃⠀⠀⠀⣀⣤⡶⠟⠛⠉⠁⠉⣷⠀⠀⠀'
puts'⠀⠀⠀⠀⠈⢿⣿⣿⣿⣿⣶⣤⣀⡉⠀⠶⠞⠛⠋⠁⠀⠀⠀⠀⠀⠀⡟⠀⠀⠀'
puts'⠀⠀⠀⠀⠀⠀⠉⠙⠛⠛⠋⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠃⠀⠀⠀'
puts'⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣶⣦⡀⠛⠀⠀⠀⠀'
puts'⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀'
puts'⠀⠀⠀⠀⣀⣤⣄⣀⡀⠀⠀⠀⠀⠀⣀⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀'
puts'⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀'
puts'⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀'
puts'⠀⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠏⠀⠀⠀⠀⠀⠀⠀'
puts'⠀⠀⠀⠀⠀⠈⠛⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀'

puts ''
puts ''
