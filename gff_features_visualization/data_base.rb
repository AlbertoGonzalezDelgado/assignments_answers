require 'csv'
require 'rest-client'
require 'bio'

class Data_base
    attr_accessor :gene_id
    attr_accessor :file_path

    @@genelist=Array.new

    # Creates a new instance of the Data_base class.
    #
    # @param gene_id [String] the gene ID to search for.
    # @param file_path [String] the file path to the gene list.
    # @return [Data_base] a new instance of the Data_base class.
    def initialize(gene_id: ,file_path:)
        @gene_id = gene_id
        @file_path = file_path
        
    end

    #This function retreives a list of genes ID from a specified file
    #
    # @param file_path [String] the file path to the gene list.
    # @return [Array<String>] a list of gene IDs.
    def initialize(gene_id: ,file_path:)
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
    end
    #This function retreives a list in which the sequences of the genes are contained (header = True ) from a specified gene ID
    #
    # @param gene_id [String] the gene ID to search for.
    # @return [Array<String>] 
    def self.get_sequences(gene_id:)
        @@sequences_list=Array.new #Creating an empty array for saving the sequences
        url=("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=fasta&id=#{gene_id}") #Searching for sequences
        response = RestClient::Request.execute(method: :get, url: url) 
        @@sequences_list << response.body #Saving the sequences with their respective header
    end

    #This function is INCOMPLETED
    def self.get_exons(gene_id:)
        @@exons=Array.new
        url=("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{gene_id}")
        response = RestClient::Request.execute(method: :get, url: url) 
        @@exons << response.body
    end
end

