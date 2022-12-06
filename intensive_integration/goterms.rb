require 'rest-client'
require_relative "fetch"
require "csv"
require "json"

class GoTerms
    attr_accessor :go_terms, :gene_list

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

    def self.go_terms
        return @go_terms
    end
end

