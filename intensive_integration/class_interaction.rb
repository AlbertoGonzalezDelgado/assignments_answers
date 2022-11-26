#Creating an Interaction Network Object to contain the members of each network
require 'rest-client'

class InteractionNetwork
    
    atrr_accesor :gene_id
    atrr_accesor :relations
    atrr_accesor :filepath
    
    @@gene_list=Array.new  #Creating an empty array for saving procesed name of genes (it has metacharacter \n)
    @@interactions=Hash.new

    def initialize(gene_id_1:, gene_id_2: ,filepath:)
        @gene_id_1 = gene_id_1
        @filepath = filepath 
    end


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