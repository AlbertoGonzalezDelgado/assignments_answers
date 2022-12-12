require 'rest-client'
require_relative "fetch"
require "csv"
require "json"

class KeggTerms

    attr_accessor :pathways, :gene_id

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

    def self.pathways
        return @pathways
    end

end

