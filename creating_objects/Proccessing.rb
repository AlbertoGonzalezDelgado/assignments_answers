
# Importing required classes ("path to classes")
require './class_cross_data.rb'
require './class_seed_stock.rb'
require './class_genes.rb'

#Checking if the arguments required are specified 
unless ARGV.length == 4  # Paths to classes are required as arguments?
    abort("FATAL ERROR: Files pathways are required. \nHELP MESSAGE: Check README.md for more information.")
end

#Checking if the files specified exist (except the output file) and aborting the program if does not.
ARGV[0..2].each do |arg|
    unless File.file?(arg)
       abort("FATAL ERROR: File #{arg} does not exist")
    end
end

#Checking if the output file already exists and asking if it should be overwrite
if File.file?(ARGV[3])
    puts "#{ARGV[3]} already exists, indicate if you want to overwrite [Y/N]" 
    overwrite=STDIN.gets.strip
    if overwrite.match(/N/) || overwrite.match(/n/)
        abort("Run cancelled")
    end
end

#Asking for amount of seeds desired to plant
puts "Indicate the amount of seeds (g):" ; seeds=STDIN.gets.strip
unless seeds.match(/\d/)                 #Aborting the script if the input is not correctly specified (it must be a number)
    abort("Check the input for number of seeds \nHELP MESSAGE: it must be a number")
end

#Loading the files pathway
seed_stock_file= ARGV[0]
gene_file= ARGV[1]
cross_data_file=ARGV[2]
output=ARGV[3]

#Loading the data from files
gene_data=Genes.load_genes(filepath: gene_file)
cross_data_data=Cross_data.load_data(filepath: cross_data_file)

sleep 1
puts "Planting #{seeds} g of seeds"
sleep 1
puts '...'
sleep 1
puts '...'
sleep 1
puts ''
stock_data=Stockdb.new_database(stockpath: seed_stock_file, newdb: output, seeds: seeds)
puts ''
sleep 1

# Accessing to grams remaind of each kind of seed and simulating planting 7 grams
puts 'Seeds have been planted. The current status of genebank is:'
puts ''
puts "#{CSV.parse(File.open(output), headers: true)}" # The output is a table where the grams of seed remains and the last date of plant is contained
sleep 1
puts ''
puts 'Now the genes that are genetically linked will be calculated'
puts '...'
sleep 1
puts '...'
sleep 1
puts ''

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

puts "Recording: #{linked_genes[0].gene_name} is genetically linked to #{linked_genes[1].gene_name} with a Chi square value of #{chi_sq.round(2)} (p < 0.05)"
sleep 1
puts ''
puts ''
sleep 1
puts 'Final Report:'
sleep 1
puts ''
puts "#{linked_genes[0].gene_name} is linked to #{linked_genes[1].gene_name}"
puts "#{linked_genes[1].gene_name} is linked to #{linked_genes[0].gene_name}"
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
