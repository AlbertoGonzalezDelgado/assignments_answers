
require_relative "class_interaction.rb"

#Checking if the arguments required are specified 

unless ARGV.length == 2
    abort("FATAL ERROR: Files pathways are required. \nHELP MESSAGE: Check README.md for more information.")
end

#Checking if the input file exists

unless File.file?(ARGV[0])
    abort("FATAL ERROR: File #{ARGV[0]} does not exist or the pathway specified is not correct")
end


#Checking if the output file already exists and asking if it should be overwrite
if File.file?(ARGV[1])
    puts "#{ARGV[1]} already exists, indicate if you want to overwrite [Y/N]" 
    stdin = ""
    until stdin == "n" || stdin == "N" || stdin == "y" || stdin == "Y"
        stdin = STDIN.gets.strip
        if stdin == "N" || stdin == "n"
            abort("Run cancelled")
        end
    end
end

#Checking if the genes in input have the correct format

gene_file = File.readlines(ARGV[0], chomp: true)

gene_file.each do |gene|
    unless gene.upcase.match(/AT\dG\d{5}/i) #ignoring case sensitive https://www.rubyguides.com/2015/06/ruby-regex/
        abort("ERROR: the gene list have some errors. #{gene} has not correct format")
    end
end

########### Main Cycle ##########

puts gene_file

InteractionNetwork.find_interactions(gene_file[0..-1])
