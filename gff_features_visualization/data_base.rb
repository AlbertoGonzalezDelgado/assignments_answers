require 'csv'
require 'rest-client'
require 'bio'

class Data_base
    attr_accessor :gene_id
    attr_accessor :file_path

    @@genelist=Array.new

    def initialize(gene_id: ,file_path:)
        @gene_id = gene_id
        @file_path = file_path
        
    end

    def self.get_genelist(file_path:)
        @@gene_list=Array.new
        unless File.file?(file_path)
            abort("FATAL ERROR: File #{file_path} does not exist or the pathway specified is not correct")
        else 
            temp_file=CSV.read(file_path, col_sep: "\t")
            temp_file.each do |line|
                unless line[0].match(/AT\dG\d{5}/i) # Ignoring case sensitive in match method https://stackoverflow.com/questions/41149008/case-insensitive-regex-matching-in-ruby
                    abort("ERROR: the gene list have some errors. #{line[0]} has not correct format")
                else
                  @@gene_list.append([line[0].upcase])
                
                end
            end
        end 

    end

    def self.get_sequences(gene_id:)
        url=("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{gene_id}")
        response = RestClient::Request.execute(method: :get, url: url) 
        puts url
        puts response.body
    end
end
