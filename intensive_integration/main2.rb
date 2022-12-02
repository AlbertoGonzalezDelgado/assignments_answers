=begin
A recent paper (DOI: 10.1371/journal.pone.0108567) executes a meta-analysis of a few thousand published co-expressed gene sets from Arabidopsis.  They break these co-expression sets into ~20 sub-networks of <200 genes each, that they find consistently co-expressed with one another.  Assume that you want to take the next step in their analysis, and see if there is already information linking these predicted sub-sets into known regulatory networks.  One step in this analysis would be to determine if the co-expressed genes are known to bind to one another.

Using the co-expressed gene list from Table S2 of the supplementary data from their analysis (I have extracted the data as text for you on the course Moodle → a list of AGI Locus Codes.  The link to the text file is below):

    use a combination of any or all of:  dbFetch, Togo REST API, EBI’s PSICQUIC REST API, DDBJ KEGG REST, and/or the Gene Ontology

    Find all protein-protein interaction networks that involve members of that gene list 

    Determine which members of the gene list interact with each other.  

USE COMMON SENSE FILTERS IN YOUR CODE! (e.g. for species, and for quality!!!).


Note:  here is where you can get the current status of all PSICQUIC services: 

http://www.ebi.ac.uk/Tools/webservices/psicquic/registry/registry?action=STATUS 

This page tells you the base URL for each database's REST API.  Read the documentation for how to construct a PSICQUIC REST URL (link is here: https://psicquic.github.io/PsicquicSpec_1_3_Rest.html)   I suggest that you use the BAR database from UToronto (it will return matches using AGI Locus Codes)


TASKS:  

    Create an “InteractionNetwork” Object to contain the members of each network

    Annotate it with any KEGG Pathways the interaction network members are part of

        both KEGG ID and Pathway Name

    Annotate it with the GO Terms associated with the total of all genes in the network

        BUT ONLY FROM THE biological_process part of the GO Ontology!

        Both GO:ID and GO Term Name

    Create a report of which members of the gene list interact with one another, together with the KEGG/GO functional annotations of those interacting members.

BONUS MARKS (to get +2% up to a perfect score)

+1% if you create a ‘uso-general’ annotation object that can hold any functional annotation

+1% if you also annotate with the AraCyc pathways (see linked file on Moodle) --> The AraCyc bonus task is not available this year, because the download website is no longer available. 
=end
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
    abort("ERROR: the gene list have some errors. #{line[0} has not correct format")
  else
  gene_list.append([line[0].upcase])
  end
end
#puts gene_list


InteractionNetwork.new(depth=3, gene_list=gene_list)
#puts InteractionNetwork.full_interactions
#puts InteractionNetwork.full_network
#puts InteractionNetwork.multi_gene_list
