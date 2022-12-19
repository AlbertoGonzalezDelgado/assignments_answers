#import required gems 
require 'rest-client'
require 'json'

# == Summary
# This class is used to search for Gene Ontology (GO) terms and KEGG pathways 
# related to a given gene.
#
class Genes
    # Get/Set the list of Gene Ontology terms.
    # @!attribute [rw]
    # @attr [Array] go_terms the array of GO terms
    
    # @attr_accesor [String] gene_id the ID of the gene being searched
    # @attr_accesor [Array] go_terms an array of GO terms related to the gene
    # @attr_accesor [Array] kegg_id an array of KEGG IDs related to the gene
    # @attr_accesor [Array] pathway an array of KEGG pathways related to the geneatrr_accesor :gene_id 
    attr_accessor :gene_id
    attr_accessor :go_terms
    attr_accessor :kegg_id
    attr_accessor :pathway

    # Searches for GO terms related to the gene.
    # @param gene_id [String] the ID of the gene being searched
    # @return [Array] an array of GO terms related to the gene
    def search_go(gene_id:)
        address ="http://togows.dbcls.jp/entry/uniprot/#{@gene_id}/dr.json"
        response = RestClient::Request.execute(method: :get,  url: address) 
        go_terms=[]
        response.body.split(/\[/).grep(/GO/)[1..response.body.length].each do |go| # We eliminate the first row (it is like a header)
            go_terms << {go.gsub(/\"/,"").split(/\,/)[0].gsub(/\n/,"").strip => go.gsub(/\"/,"").split(/\,/)[1].gsub(/\n/,"").strip}
        end
        return go_terms
    end
    
    # Searches for KEGG pathways related to the gene.
    #
    # @param gene_id [String] the ID of the gene being searched
    # @return [Array] an array of KEGG pathways related to the gene
    def search_kegg(gene_id:)

        address ="http://togows.org/entry/uniprot/#{gene_id}/dr.json"
        response = RestClient::Request.execute(method: :get, url: address)  
        JSON.parse(response.body)[0]['KEGG'].each do |kegg|
            kegg_id << kegg[0]
        end
        kegg_id.each do |id|
            address ="http://togows.org/entry/kegg-genes/#{id}.json"
            response = RestClient::Request.execute(
            method: :get, url: address)  
             JSON.parse(response.body)[0]['pathways'].each do |path|
               pathway << {path[0] => path[1]}
             end
        end
        return pathway
    end
end
