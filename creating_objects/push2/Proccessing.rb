
# Importing required classes ("path to classes")
require './class/class_cross_data.rb'
require './class/class_seed_stock.rb'
require './class/class_genes.rb'
require './class/class_seed_stock_DataBase.rb'

#Checking if the arguments required are specified 
unless ARGV.length == 4
    abort("FATAL ERROR: Files pathways are required. \nHELP MESSAGE: Check README.md for more information.")
end

# Checking if the files specified exist (except the output file) and aborting the program if does not.
ARGV[0..2].each do |arg|
    unless File.file?(arg)
       abort("FATAL ERROR: File #{arg} does not exist")
    end
end

# Checking if the output file already exists and asking if it should be overwrite.
# Any other character than N|n|Y|y will abort the run

if File.file?(ARGV[3])
    puts "#{ARGV[3]} already exists, indicate if you want to overwrite [Y/N]" 
    stdin = ""
    until stdin == "n" || stdin == "N" || stdin == "y" || stdin == "Y"
        stdin = STDIN.gets.strip
        if stdin == "N" || stdin == "n"
            abort("Run cancelled")
        end
    end
end

# Asking for amount of seeds desired to plant
puts "Indicate the amount of seeds (g):"
seeds=STDIN.gets.strip
unless seeds.match(/\d/)               #Aborting the script if the input is not correctly specified (it must be a number)
    abort("Check the input for number of seeds \nHELP MESSAGE: it must be a number")
end

# Loading the files pathway
seed_stock_file=ARGV[0]
gene_file=ARGV[1]
cross_data_file=ARGV[2]
output=ARGV[3]

# Loading the data from files
Genes.load_data(filepath: gene_file)
CrossData.load_data(filepath: cross_data_file)
seedstock_database = StockDB.new
seedstock_database.load_from_file(filepath: seed_stock_file)

sleep 1
puts "Planting #{seeds} g of seeds"
sleep 1
puts '...'
sleep 1
puts '...'
sleep 1
puts ''

planted_table = seedstock_database.plant_seeds(grams: seeds)
seedstock_database.new_database(new_db: output)

puts ''
sleep 1

# Accessing to grams remaind of each kind of seed and simulating planting 7 grams
puts 'Seeds have been planted. The current status of genebank is:'
puts ''
print planted_table
# The output is a table where the grams of seed remains and the last date of plant is contained
sleep 1
puts ''
puts 'Now the genes that are genetically linked will be calculated'
puts '...'
sleep 1
puts '...'
sleep 1
puts ''

## We get the crosses that provide results of linked genes.
linked_cross_array, chi_sq_array = CrossData.get_linked()

## We iterate the array of linked crosses and process each cross separately. Even though there is only one linked cross,
## I decided to do this to automatize the process in the event of introducing new linked crosses in the table.
linked_cross_array.each {|linked_cross|

    ## We retrieve the Seed Stock objects involved in the cross
    linked_seed1 = seedstock_database.get_SeedStock(seedstock_id: linked_cross.parent1)
    linked_seed2 = seedstock_database.get_SeedStock(seedstock_id: linked_cross.parent2)

    ## We retrieve the genes filtering by their ids, and we return the gene names
    linked_gene1 = Genes.get_Gene(gene_id: linked_seed1.mutant_gene_id)
    linked_gene2 = Genes.get_Gene(gene_id: linked_seed2.mutant_gene_id)

    # Store linkage data in instance variables
    linked_gene1.linkage = linked_gene2
    linked_gene2.linkage = linked_gene1

    # Printing linked genes
    puts "Recording: #{linked_gene1.gene_name} is genetically linked to #{linked_gene2.gene_name} with a Chi square value of #{chi_sq_array[0].round(2)} (p < 0.05)"
    sleep 1
    puts ""
}
puts ''
sleep 1
puts 'Final Report:'
sleep 1
puts ''

# Print final report of genes with linkage
Genes.all_genes.each do |gene|
    if gene.linkage.instance_of?(Genes) then
        puts "#{gene.gene_name} is linked to #{gene.linkage.gene_name}"
    end
end

sleep 1
puts ''
puts ''
sleep 1

# Just printing a seed growing
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
