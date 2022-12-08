require 'csv'
require 'rest-client'
require 'bio'

class Data_base
    attr_accessor :gene_id
    attr_accessor :file_path
    attr_accessor :sequence

    @@genelist=Array.new

    def initialize(gene_id: ,file_path:)
        @gene_id = gene_id
        @file_path = file_path
        
    end
 #This function retreives a list of genes ID from a specified file
    def self.get_genelist(file_path:)
        @@gene_list=Array.new    #Creating an empty array for saving the list of genes
        unless File.file?(file_path) #Checking if the file path is correct
            abort("FATAL ERROR: File #{file_path} does not exist or the pathway specified is not correct")
        else 
            temp_file=CSV.read(file_path, col_sep: "\t")
            temp_file.each do |line|    #Checking if the genes have the correct format
                unless line[0].match(/AT\dG\d{5}/i) # Ignoring case sensitive in match method https://stackoverflow.com/questions/41149008/case-insensitive-regex-matching-in-ruby
                    abort("ERROR: the gene list have some errors. #{line[0]} has not correct format")
                else
                  @@gene_list.append([line[0].upcase]) #Saving the gene list
                
                end
            end
        end   

    end

#This function retreives a list in which the sequences of the genes are contained (header = True ) from a specified gene ID
    def self.get_sequences(gene_id:)
        @@sequences_list=Array.new #Creating an empty array for saving the sequences
        url=("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=fasta&id=#{gene_id}") #Searching for sequences
        response = RestClient::Request.execute(method: :get, url: url) 
        body=response.body.split(/\:/)[6][1..-1]
        @@sequences_list << Bio::Sequence.auto(body) #Saving the sequences without the header (all the sequences have a number in the beggining so [1..-1 to eliminate them])

    end

#This function is INCOMPLETED
    def self.get_exons(gene_id:)
        sequence=self.get_sequences(gene_id: gene_id)
            #next unless feature.feature == "exon"
            #match = feature.match(/CTTCTT/i).position
            #start,stop = match[1], match[2]
            #exon_positions << [start,stop]
        end


    end
end
