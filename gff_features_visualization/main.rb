require './data_base.rb'
require 'csv'
require 'bio'

#Checking if the input file exists
unless File.file?(ARGV[0])
    abort("FATAL ERROR: File #{ARGV[0]} does not exist or the pathway specified is not correct")
end

gene_file_path = ARGV[0]

gene_list=Data_base.get_genelist(file_path: gene_file_path)

sequences_list=Array.new
exons_list=Array.new

gene_list.each do |gene|
    sequences_list << Data_base.get_sequences(gene_id: gene[0])
    exons_list << Data_base.get_exons(gene_id: gene[0])
end
puts exons_list
