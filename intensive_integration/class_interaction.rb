#Creating an Interaction Network Object to contain the members of each network

require 'rest-client'

class InteractionNetwork
    
    attr_accessor :gene_id
    attr_accessor :relations
    attr_accessor :filepath
    
    @@gene_list=Array.new  #Creating an empty array for saving procesed name of genes (it has metacharacter \n)
    @@interactions=Hash.new

    def initialize(gene_id_1:, gene_id_2: ,filepath:)
        @gene_id_1 = gene_id_1
        @filepath = filepath
        find_interactions(gene_id_1)
    end

    def self.find_interactions(gene_p)
        all_interactions = {1 => {} , 2 => {} , 3 => {}}
        #all_scores = Hash.new
        iter_genes = gene_p #Esta lista deberia ser el output de la función que lea el archivo con los genes

        all_interactions.keys.each do |iter|
        
          last_interactions = Hash.new #Temp hash to save the results from the interaction search
          last_records = Array.new #Temp array to save all the genes found in the search instead of one array per key
          
          iter_genes.each do |iter_gene|
              upcase_gene = iter_gene.upcase # Convert gene ID to uppercase
              address = "http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{upcase_gene}?format=tab25"
              response = RestClient::Request.execute(method: :get, url: address)
              intact_data = response.body.split(/\n/)
          
              record_list = Array.new
              score_list = Array.new
          
              intact_data.each do |record|
              intact_gene1 = record.split(/\t/)[2].split(/\|/).grep(/^ensemblplants/)  # We filter to extract ensembleplants id
              intact_gene2 = record.split(/\t/)[3].split(/\|/).grep(/^ensemblplants/)  # from columns 2 and 3 of each record.
              intact_genes = intact_gene1 + intact_gene2                               # Combine records from both columns. 
              
              score = record.split(/\t/).pop.split(/\:/).pop   # Extract the interaction score of each record.
              
              # For some genes, we obtain interaction reports for different splicing variants (.1, .2, .3)
              # For each gene record, we extract only the gene ID using regular expressions
              
              intact_genes_filtered = Array.new
              intact_genes.each {|splicing| intact_genes_filtered << splicing.match(/AT\dG\d*/).to_s}
              
              # Finally, we remove duplicates from our final interaction records.
              
              intact_genes_filtered.uniq!
              
              #print "\n\n> Record:\n", intact_genes_filtered
              #print "\nScore: ", score
              
          ''' With this process, we obtain a set of inteaction records for each gene, each record containing one
              or more interactors. Different records might share common interactors and even contain the query gene.
              
              We want to obtain a final list of unique interactors for each query gene, so we need to remove interactor
              redundancy and interaction of the query gene with itself.
          '''
              # Introduce a quality filter
              unless score.to_f < 0.5
                  # Combine the interactors from different records
                  record_list += intact_genes_filtered       
                  # Remove redundant interactors
                  record_list.uniq!                          
                  # Remove the query gene from its interactor list
                  record_list.delete(upcase_gene.to_s)       
                  
                  #Doing the same but in order to merge all the genes together in a single array
                  last_records += intact_genes_filtered
                  last_records.uniq!
                  last_records.delete(upcase_gene.to_s)
                  #EL SCORE NO SE GUARDA TRAS CADA LOOP, PERO COMO SOLO LO USAMOS DE FILTRO TAMPOCO DEBERÍA IMPORTAR
                  score_list.append score
              end
            end
            print "\n\n", upcase_gene.to_s, " interactors: ", record_list.length #printing for testing
            last_interactions[upcase_gene.to_s] = record_list #saving the result into the temp hash
            print "\n", last_interactions[upcase_gene.to_s] #printing for testing, can be removed
        end
        #Cleaning empty arrays that appear when there's no interacion to be found
        clean_interactions = last_interactions.delete_if {|key,value| value.empty? }
        #Using the results from this loop for the next iteration

        iter_genes = last_records
        #Saving the interactions into hash before starting the next loop
        all_interactions[iter] = clean_interactions
        end

        ## Finding the common elements of the three interaction hashes
        interaction_network = Array.new
        all_interactions[3].each do |key3, value3| #Starting with the last hash, but could start with anyone.
        if (all_interactions[1].keys & all_interactions[3][key3]).any? #If they share something in common
            (all_interactions[1].keys & all_interactions[3][key3]).each do |key1| #Iterate over common genes
            if (all_interactions[1][key1] & all_interactions[2].keys).any? #Now search those genes in hash2
                (all_interactions[1][key1] & all_interactions[2].keys).each do |key2|
                if all_interactions[2][key2].include? key3
                    #If the element reaches this part of the conditional it should mean that its in the three hashes
                    interaction = [key1, key2, key3] #If the network has a repeated element it doesn't count
                    interaction_network.append interaction if interaction.length == interaction.uniq.length
                end
                end
            end
            end
        end
        end
        print "\n \n Networks found: #{interaction_network.length} \n", interaction_network
    end
end

=begin
    def read_file(filepath:)
    gene=Array.new #Creating an empty array for saving each line of the document
    File.foreach("intensive_integration/documents/ArabidopsisSubNetwork_GeneList.txt"){ |line|  gene <<line } #Saving each line of the document# in the array. Source: https://www.rubyguides.com/2015/05/working-with-files-ruby/ 
    gene.each do |line| 
      @@gene_list << line.gsub("\n",'') #Eliminating metacharacter \n in each line. 
    end   #The difference between gene and gene_list array is that in the second one we can access to each value gene_list[1]
     # and the return has not metacharacter \n. 
        return @@gene_list
    end

#############################################INCOMPLETE########################################
    def obtain_interaction_network
           require 'rest-client'   # This access to the page of each gene 
      interactor1={}
      interactor2={}
      
      punctuations={}
    #We have to search in other data base the interactions
      intactstring=Array.new
      gene_p.each do |gene_id|
        address = "http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{gene_id}?format=tab25"
        response = RestClient::Request.execute(method: :get, url: address)
        record = response.body
        record_su= record.split(/\n/) #split the string to substrings based on new line pattern: https://www.geeksforgeeks.org/ruby-string-split-method-with-examples/
                                      #separating by each interaction
        
        temp_arr1=[]
        temp_arr2=[]
        punctuation_arr=[]
      
        record_su.each do |line|      
         #   unless line.split(/\t/)[2].split(/\|/).grep(/^ensemblplants/)[0]? and f line.split(/\t/)[3].split(/\|/).grep(/^ensemblplants/)[0]?
          #    next
           # else
          tester1 = line.split(/\t/)[2].split(/\|/).grep(/^ensemblplants/)[0]
          tester2 = line.split(/\t/)[3].split(/\|/).grep(/^ensemblplants/)[0]
              
          punctuation = line.split(/\t/)[-1].split(/\:/)[1]
          
          unless tester1.nil? || tester2.nil? || punctuation.to_f < 0.5 
            temp1 = tester1.match(/:(.*)(.*)/)[1..]
            temp2 = tester2.match(/:(.*)(.*)/)[1..]
            
            #concatenating proteins that interact in array
            temp_arr1.append(temp1[0])
            temp_arr2.append(temp2[0])
            punctuation_arr.append(punctuation)
            
              #Finding duplicates
            dup_finder1=temp_arr1.each_index.select { |index| temp_arr1[index] == temp1[0]}
            dup_finder2=temp_arr2.each_index.select { |index| temp_arr2[index] == temp2[0]}
            
            #If the interaction was already in, remove it from the array
            if (dup_finder1.length > 1 && dup_finder2.length > 1) && \
                ((dup_finder2-dup_finder1).empty? || (dup_finder1-dup_finder2).empty?)
              puts"deleting last interaction: 1: #{temp_arr1}.length / 2: #{temp_arr2}"
              temp_arr1.pop
              temp_arr2.pop
              punctuation_arr.pop
              puts"DONE 1: #{temp_arr1} , 2: #{temp_arr2}"
      
            end
          end
          #Saving the results for each gene ID
          interactor1[gene_id] = temp_arr1
          interactor2[gene_id] = temp_arr2
          punctuations[gene_id] = punctuation_arr
        end
      end
    end
 end
=end
