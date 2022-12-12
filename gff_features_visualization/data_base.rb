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

        #Saving sequences
        @@sequences_list=Array.new #Creating an empty array for saving the sequences
        url=("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=fasta&id=#{gene_id}") #Searching for sequences
        response = RestClient::Request.execute(method: :get, url: url) 
        body=response.body.split(/\:/)[6][1..-1]
        @@sequences_list << Bio::Sequence.auto(body) #Saving the sequences without the header (all the sequences have a number in the beggining so [1..-1 to eliminate them])

        #Searching for positions of exons 
        url=("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{gene_id}") #Searching for sequences
        response = RestClient::Request.execute(method: :get, url: url) 
        record = Bio::EMBL.new(response)
        seq = record.to_biosequence
        
        @@exon_seqs = Array.new()
        record.features.each do |feature|
            
            next unless feature.feature == "exon"

            feature.locations.each do |loc|

                strand = feature.locations[0].strand
                start, stop = loc.from, loc.to
                exon_seq = seq.subseq(start, stop)

                next if exon_seq == nil

                next if start == stop
                
                @@exon_seqs.append([[start, stop],exon_seq])


                if strand == +1
                    
                    start_f = exon_seq.enum_for(:scan, /(?=(cttctt))/i).map { Regexp.last_match.begin(0) + 1} # +1 so it is 1-indexed
                
                    next if start_f.empty? 

                    p start_f.map{|start| [start-1, start+5]}
                end

                if strand == -1
                                       
                    start_f = exon_seq.enum_for(:scan, /(?=(gaagaa))/i).map { Regexp.last_match.begin(0) + 1} # +1 so it is 1-indexed
                
                    next if start_f.empty? 

                    p start_f.map{|start| [start-1, start-5]}
                end




            end
        @@exon_seqs.each do |exon|
            loc =  exon[0]
            seq =  exon[1]
    
    
            
        end
        end 

        
=begin

        @@exon_positions = @@exon_positions[1..-1]


        #Searching for the position of the contig 
        datafile = Bio::FlatFile.auto("#{gene_id}.embl")
        entry =  datafile.next_entry   # this is a way to get just one entry from the FlatFile
        @@contig_position=[]
        entry.features.each do |feature|
            next unless feature.feature == "misc_feature"
            match= feature.qualifiers[0].value.match(/(\d+)\.\.(\d+)/)
            start,stop = match[1], match[2]
            @@contig_position << [start,stop]
        end

      
        #From absolute position to relative position
        @@relative_position=[]

        @@exon_positions.each do |pos|
            init=@@contig_position[0][0]
            start,stop= pos[0].to_i-init.to_i,pos[1].to_i-init.to_i
            @@relative_position << [start,stop]
        end
        

        puts @@sequences_list[0].length #??????????¿?¿?¿?¿?¿?¿?¿?¿?¿?¿?¿?¿?¿?¿?¿¿¿¿
        p @@exon_positions
        #p entry

        #Searching for ccttctt match in exons
        #@@sequences_match=[]
        #@@exon_positions.each do |pos|
        #    puts pos[0]
        #    puts ""
        #    start, stop= (pos[0].to_i-1),(pos[1].to_i-1) #-1 due to the position in a string starts from 0 
        #    exon = @@sequences_list[0][start..stop] 
        #    puts exon
        #    puts pos[1]
            #next unless exon.match(/cttctt/i)
           # puts exon.match(/cttctt/i)
        #end
        #Removing the file created (we don't want to waste memory) 
        #File.delete("#{gene_id}.embl")

=end
    end
end
