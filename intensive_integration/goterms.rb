#import required gems
require 'rest-client'
require "csv"
require_relative "fetch"
require "json"

# == GOTerms
# GoTerms class that retrieves Gene Ontology (GO) terms for a given list of genes.
#
class GoTerms
    
    # Get/Set the list of Gene Ontology terms.
    # @!attribute [rw]
    # @attr [Array] the array of GO terms
    attr_accessor :go_terms
    # Get/Set the list of Genes.
    # @!attribute [rw]
    # @attr [Array] the array of query genes
    attr_accessor :gene_list

  
    # Initialize the GoTerms instance given a gene list.
    #
    # @param gene_list [Array] the array of genes

    def initialize(gene_list=nil)
        genes = gene_list.join(",")
        address ="http://togows.dbcls.jp/entry/uniprot/#{genes}/dr.json"
        response = RestClient::Request.execute(  #  or you can use the 'fetch' function we created last class
        method: :get,
        url: address) 

        @go_terms=[]
        response.body.split(/\[/).grep(/GO/)[1..response.body.length].each do |go| # I eliminate the first row (it is like a header)
            if go.gsub(/\"/,"").split(/\,/)[1].gsub(/\n/,"").strip.match("^P:.*")
                @go_terms << {go.gsub(/\"/,"").split(/\,/)[0].gsub(/\n/,"").strip => go.gsub(/\"/,"").split(/\,/)[1].gsub(/\n/,"").strip}
            end
        end
    end


    # Return the Gene Ontology array
    #
    # @return [Array] the go_terms array
    def self.go_terms
        return @go_terms
    end
end

