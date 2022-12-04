
require 'rest-client'
require 'json'

class Genes
    atrr_accesor :gene_id 
    atrr_accesor :go_terms
    atrr_accesor :kegg_id
    atrr_accesor :pathway

    def search_go(gene_id:)
        address ="http://togows.dbcls.jp/entry/uniprot/#{@gene_id}/dr.json"
        response = RestClient::Request.execute(method: :get,  url: address) 
        go_terms=[]
        response.body.split(/\[/).grep(/GO/)[1..response.body.length].each do |go| # We eliminate the first row (it is like a header)
            go_terms << {go.gsub(/\"/,"").split(/\,/)[0].gsub(/\n/,"").strip => go.gsub(/\"/,"").split(/\,/)[1].gsub(/\n/,"").strip}
        end
        return go_terms
    end

    def search_kegg(gene_id:)

        address ="http://togows.org/entry/uniprot/#{@gene_id}/dr.json"
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
