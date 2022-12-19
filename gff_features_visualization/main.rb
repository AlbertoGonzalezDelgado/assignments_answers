require './data_base.rb'
require 'csv'
require 'bio'


#Checking the number of inputs
unless ARGV.length == 3
    abort("FATAL ERROR: Files pathways are required. \nHELP MESSAGE: Check README.md for more information.")
end

#Checking if the input file exists
unless File.file?(ARGV[0])
    abort("FATAL ERROR: File #{ARGV[0]} does not exist or the pathway specified is not correct")
end

gene_file_path = ARGV[0]

gene_list=Data_base.get_genelist(file_path: gene_file_path)

sequences_list=Array.new

exons_list=Array.new

genes_without = Set[]
gff_lines = Set[]
gene_list.each do |i|
    sequence=i[0]
    forward, reverse = Data_base.get_sequences(gene_id: sequence)

    if forward.empty? and reverse.empty?
        genes_without.add(sequence)
        
    else
        unless forward.empty?
            forward.each do |l|
                gff_lines.add(l)
            end
        end

        unless reverse.empty?
            reverse.each do |l|
                gff_lines.add(l)
            end
        end
    end
end

outfile = File.new(ARGV[1], "w+")

outfile.write("##GFF3\n")
gff_lines.each do |i|
  outfile.write("#{i.join("\t")}\n")
end
outfile.close


p "GFF Done"

outfile = File.new(ARGV[2], "w+")

outfile.write("##Final Report\n")

outfile.write("Out of #{gene_list.length} input genes, #{genes_without.length} did contain the cttctt motif in their exons\n")


genes_without.each do |i|
  outfile.write("#{i} contains no cttctt motif \n")
end
outfile.close

