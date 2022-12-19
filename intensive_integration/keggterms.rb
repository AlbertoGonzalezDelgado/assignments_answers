require 'rest-client'
require_relative "fetch"
require "csv"
require "json"


# == KeggTerms
#
# This class called KeggTerms is used to retrieve information about pathways associated with a given list of genes.
#
# == Summary 
#
# The class has two attributes, pathways and gene_id, which can be accessed and modified using the attr_accessor method.
# The class has a single method, initialize, which is a constructor method that is called whenever a new instance of the class is created. 
# The self.pathways method is defined as a class method, which can be called on the KeggTerms class itself rather than on an instance of the class.
class KeggTerms

    # Saves the gene ID that is going to be used for analysis.
    # @!attribute [rw]
    # @return [string] pathway were the gene takes part on.
    attr_accessor :pathways
    
    # Saves the gene ID that is going to be used for analysis.
    # @!attribute [rw]
    # @return [string] a single gene_id.
    attr_accessor :gene_id

    # The initialize method takes an optional parameter gene_list, which is expected to be an array of gene names. If gene_list is not provided, it defaults to nil.
    # The initialize method begins by concatenating the gene names in the gene_list array into a single string, separated by commas.
    # It then uses this string to construct a URL and sends a GET request to this URL using the RestClient library.
    # The response is parsed as a JSON object and stored in a variable called kegg_list.
    # Next, the initialize method iterates over each element in kegg_list and sends another GET request to a different URL, using the current element as a parameter.
    # The response to this request is also parsed as a JSON object, and the pathways associated with the current gene are extracted and stored in the pathways attribute of the KeggTerms instance.
    # @param gene_list [array<string>] list containing gene IDs
    def initialize(gene_list=nil)
        
        genes = gene_list.join(",")
        address ="http://togows.org/entry/uniprot/#{genes}/dr.json"
        response = RestClient::Request.execute(method: :get, url: address)  
        
        kegg_list=[]
        kegg_terms=[]
        JSON.parse(response.body)[0]['KEGG'].each do |kegg|
            kegg_list << kegg[0]
        end

        @pathways=[]
        kegg_list.each do |id|
            address ="http://togows.org/entry/kegg-genes/#{id}.json"
            response = RestClient::Request.execute(method: :get, url: address)  
            JSON.parse(response.body)[0]['pathways'].each do |path|
                @pathways << {path[0] => path[1]}
            end
        end
     
    end

    # This method simply returns the value of the @pathways instance variable.
    # @return [string] pathways instance variable.
    def self.pathways
        return @pathways
    end

end

