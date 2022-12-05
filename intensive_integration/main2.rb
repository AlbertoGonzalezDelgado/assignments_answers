require 'rest-client'
require_relative "fetch"
require "json"
require_relative "InteractionNetwork"
require_relative"goterms"

# Checking if the arguments required are specified 

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

gene_information = ARGV[0]

gene_info = {}
taxid = "taxid:3702\(arath\)" # Since we are grepping make sure regex is consistant
gene_file = File.readlines(ARGV[0], chomp: true)

gene_list = []
gene_file.each do |line|
  unless line.match(/AT\dG\d{5}/i)
    abort("ERROR: the gene list have some errors. #{line} has not correct format")
  else
  gene_list.append([line.upcase])
  end
end
#puts gene_list


InteractionNetwork.new(depth=3, gene_list=gene_list)
paths = InteractionNetwork.significant_paths

interactors = paths.keys.to_a # the proteins in the provided list that interact
path =  paths.values.to_a # the shortest path between said proteins

=begin
interactors.each do |protein|
  a, b = protein[0..1]
  a = GoTerms.new(a)
  b = GoTerms.new(b)
  puts a.go_terms
  puts b.go_terms
end
=end
puts "#####################################"
puts "Final Report:"
puts "#{interactors.length} significant interactions found with min. quality IntactMiscore > 0.55, and depth = 3 from #{InteractionNetwork.number_significant_components} connected components"

(0..interactors.length-1).each do |i|
  puts "#{interactors[i].join("<->")} via [#{path[i]}]"
end

number_hits = interactors.flatten.uniq
puts "Found #{number_hits.length} out of #{gene_list.length} genes from the original list interact with each other with less than 3 nodes between"

puts "\n#####################################"
puts "Go Term Analysis:"





#puts InteractionNetwork.full_interactions
#puts InteractionNetwork.full_network
#puts InteractionNetwork.multi_gene_list



