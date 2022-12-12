require './data_base.rb'
require 'csv'
require 'bio'

#Checking the number of inputs
#unless ARGV.length == CHANGE FROM THE NUMBER WE NEED
#    abort("FATAL ERROR: Files pathways are required. \nHELP MESSAGE: Check README.md for more information.")
#end

#Importing file
gene_file_path = ARGV[0]

gene_list=Data_base.get_genelist(file_path: gene_file_path)

sequences_list=Array.new

exons_list=Array.new

#gene_list.each do |gene|
#    sequences_list << Data_base.get_sequences(gene_id: gene[0])
#end

(0..10).each do |i|
    sequence=gene_list[i][0]
    Data_base.get_sequences(gene_id: sequence)
end
