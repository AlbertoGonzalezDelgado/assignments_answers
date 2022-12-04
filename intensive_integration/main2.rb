require 'rest-client'
require_relative "fetch"
require "csv"
require "json"
require_relative "InteractionNetwork"

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
gene_file = CSV.read(gene_information, col_sep: "\t")

s2 = fetch(url: "https://doi.org/10.1371/journal.pone.0108567.s001")
gene_list = []
gene_file.each do |line|
  unless line[0].match(/AT\dG\d{5}/i)
    abort("ERROR: the gene list have some errors. #{line[0]} has not correct format")
  else
  gene_list.append([line[0].upcase])
  end
end
#puts gene_list


InteractionNetwork.new(depth=3, gene_list=gene_list)
paths = InteractionNetwork.significant_paths

p paths.keys
puts paths.values
#puts InteractionNetwork.full_interactions
#puts InteractionNetwork.full_network
#puts InteractionNetwork.multi_gene_list

=begin
response = RestClient::Request.execute(  #  or you can use the 'fetch' function we created last class
  method: :get,
  url: "https://doi.org/10.1371/journal.pone.0108567",
  headers: {accept: 'text/plain'}
#  headers: {accept: 'application/json'}
#  headers: {accept: 'text/turtle'}
)  
puts response.body.force_encoding('UTF-8')
=end
#puts s2.body.force_encoding('UTF-8')



base_url = "www.ebi.ac.uk/intact/ws/interaction/findInteractions/{query}"
#puts gene_info

