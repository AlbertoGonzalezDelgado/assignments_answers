require 'rest-client'
require_relative "fetch"
require "json"
require_relative "InteractionNetwork"
require_relative "goterms"
require_relative "keggterms"

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
paths = Hash[paths.sort_by { |k, v| v.length }]
interactors = paths.keys.to_a # the proteins in the provided list that interact
path =  paths.values.to_a # the shortest path between said proteins

go_terms = GoTerms.new(interactors)
kegg_terms = KeggTerms.new(interactors)

#puts go_terms
outfile = File.new(ARGV[1], "w+")

outfile.write("#####################################\n")
outfile.write("Final Report:\n")
outfile.write("#{interactors.length} significant interactions found with min. quality IntactMiscore > 0.55, and depth = 3 from #{InteractionNetwork.number_significant_components} connected components:\n")

(0..interactors.length-1).each do |i|
  outfile.write("#{interactors[i].join("<->")} via [#{path[i]}]\n")
end

number_hits = interactors.flatten.uniq
outfile.write("\nFound #{number_hits.length} out of #{gene_list.length} genes from the original list interact with each other with less than 3 nodes between.\n")

outfile.write("\n#####################################\n")
outfile.write("Go Term Analysis:\n\n")

outfile.write(go_terms.go_terms.to_a.uniq.join("\n"))

outfile.write("\n#{go_terms.go_terms.to_a.uniq.length} Go Terms shared by all #{number_hits.length} genes.\n")

outfile.write("\n#####################################\n")
outfile.write("\nKegg Term Analysis:\n")

outfile.write(kegg_terms.pathways.to_a.uniq)

outfile.write("\n#{kegg_terms.pathways.to_a.uniq.length} Kegg Terms shared by all #{number_hits.length} genes.")
outfile.close()
