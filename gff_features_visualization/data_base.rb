require 'csv'
require 'rest-client'
require 'bio'

# == Data_base
#
# Class that searches for genes based on gene IDs into EMBL-EBI database, for storing and retrieving information about genes.
# 
# == Summary
#
# This class can be used to retrieve features and information about the genes.
# The class has four instance variables: gene_id, file_path, sequence, and @@genelist.
# The gene_id and file_path variables are accessible through read and write attributes (attr_accessor).
# The @@genelist variable is a class variable that is an array and is used to store a list of genes.
#
# @authors Julian Elijah Politsch, Angelo D'angelo, Alberto Gonzalez, Adrian Barreno, Pablo Mata
class Data_base

    # Saves the gene ID that is going to be used for analysis.
    # @!attribute [rw]
    # @return [string] a single gene_id.
    attr_accessor :gene_id

    # Contains the sequence of the gene.
    # @!Attribute [rw]
    # @return [String] a gene sequence.
    attr_accessor :sequence
    # Array of arrays containing the start and stop positions of each exon and its full sequence.
    # @!attribute [rw]
    # @return [Array] array of arrays containing exon information.
    attr_accessor :exon_seqs
    # Feature information in forward position (GFF3 format).
    # @!attribute [rw]
    # @return [Set] feature information.
    attr_accessor :forward_features

    # Feature information in reverse position (GFF3 format).
    # @!attribute [rw]
    # @return [Set] feature information.
    attr_accessor :reverse_features

    # Array containing the complete gene list.
    @@gene_list = Array.new
    # Array for saving the complete list of gene sequences.
    @@sequences = Array.new
    # Path to the file containing the genes.
    @@file_path = nil

    # The initialize method is a constructor that is called when a new instance of the Data_base class is created. 
    # It takes two arguments: gene_id and file_path, and sets the values of the corresponding instance variables.
    #
    # @param gene_id [string] a gene ID
    # @param file_path [string] a file containing gene IDs
    def initialize(gene_id:, sequence: nil, exon_seqs: nil, forward_features: nil, reverse_features: nil)
        @gene_id = gene_id
        @sequence = sequence
        @exon_seqs = exon_seqs
        @forward_features = forward_features
        @reverse_features = reverse_features
    end


    # The self.get_genelist method is a class method that takes a file_path argument and returns an array of gene IDs. 
    # It first checks if the file specified by the file_path argument exists. If it does not, it aborts the program with an error message.
    # If the file does exist, it reads the contents of the file and checks each line to see if it is a valid gene ID. If it is not, it aborts the program with an error message.
    # If the line is a valid gene ID, it is added to the @@gene_list array.
    #
    # @param file_path [string] takes the path to the specified file containing gene IDs
    # @return [array<string>] an array with the gene IDs
    def self.get_genelist(file_path:)
        @@file_path = file_path
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
    
    #The self.get_sequences method is a class method that takes a gene_id argument and returns a list of sequences for the specified gene.
    #It first retrieves the sequences for the gene from a remote database, and saves them in the @@sequences_list array. 
    #It then retrieves information about the positions of exons in the gene, and saves them in the @@exon_seqs array. Finally, it returns the @@sequences_list array.
    #
    # @param gene_id [string] takes a single gene_id
    # @return list [Array<String>]
    def self.get_sequence(gene_id:)

        #This function retreives a list in which the sequences of the genes are contained (header = True ) from a specified gene ID

        forward_positions = Set[]
        reverse_positions = Set[]

        #Saving sequences
        url=("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=fasta&id=#{gene_id}") #Searching for sequences
        response = RestClient::Request.execute(method: :get, url: url) 
        sequence = response.body.split("\n")[3..].join("")    # Remove the fasta header
        @@sequences << Bio::Sequence.auto(sequence)    # Saving the sequences without the header (all the sequences have a number in the beggining so [1..-1 to eliminate them])

        #Searching for positions of exons 
        url=("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{gene_id}") #Searching for sequences
        response = RestClient::Request.execute(method: :get, url: url) 
        record = Bio::EMBL.new(response)
        seq = record.to_biosequence
        
        exons = Array.new

        record.features.each do |feature|
            
            chromosome, abs_start, abs_stop = record.sv.split(":")[2..4].map{|s| s.to_i}

            next unless feature.feature == "exon"

            exon_range = feature.position.split("..").map{|s| s.to_i}

            feature.locations.each do |loc|

                strand = feature.locations[0].strand
                start, stop = loc.from, loc.to
                exon_seq = seq.subseq(start, stop)

                next if exon_seq == nil

                next if start == stop
                
                exons << [[start, stop], exon_seq]

                if strand == +1
                    
                    start_f = exon_seq.enum_for(:scan, /(?=(cttctt))/i).map { Regexp.last_match.begin(0) + 1} # +1 so it is 1-indexed
                
                    next if start_f.empty? 

                    location = start_f.map{|pos| [pos+abs_start+start-2, pos+abs_start+start + 3]}

                    location.each do |loc|

                        forward_positions.add(["Chr#{chromosome}", "Ruby", "repeat_component", loc[0], loc[1], ".", "+", ".", "Type = Forward_CTTCTT; Gene_ID = #{gene_id}"])
                    end

                end

                if strand == -1
                                       
                    start_f = exon_seq.enum_for(:scan, /(?=(aagaag))/i).map { Regexp.last_match.begin(0) + 1} # +1 so it is 1-indexed
                
                    next if start_f.empty? 

                    location = start_f.map{|pos| [pos+abs_start+start-2, pos+abs_start+start  + 3]}

                    location.each do |loc|

                        reverse_positions.add(["Chr#{chromosome}", "Ruby", "repeat_component", loc[0], loc[1], ".", "-", ".", "Type = Reverse_CTTCTT; Gene_ID = #{gene_id}"])

                    end
                end
            end
        end

        return Data_base.new(
                    gene_id: gene_id, \
                    sequence: sequence, \
                    exon_seqs: exons, \
                    forward_features: forward_positions, \
                    reverse_features: reverse_positions)

    end
'''    
    database = Data_base.get_sequence(gene_id: "AT1G02280")

    puts database.sequence
    puts database.gene_id
    puts database.exon_seqs
    puts database.forward_positions
    puts database.reverse_positions
'''
end
