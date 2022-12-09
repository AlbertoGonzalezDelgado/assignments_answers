require 'rest-client'
require_relative "fetch"
require "csv"
require "json"
require 'rgl/base'
require 'rgl/adjacency'
require 'rgl/connected_components'
require "rgl/implicit"
require "rgl/dijkstra"
require "rgl/edge_properties_map"

class InteractionNetwork
    
    """
    InteractionNetwork class takes as input a list of gene ID's and 
    creates a RGL adjacency network with uniform (1) edge weights.
    
    Result: a hash containing significant interactions between the gene
    list as @@significant_paths where keys = [geneA, geneB] and values = 
    [dijkstra_shortest_path from A to B]
    
    """
    attr_accessor :gene_list

    #All networks of all objects called, representing the full known network
    @@full_network = RGL::AdjacencyGraph.new
    @@edge_weights = {}
    @@significant_paths = {}
    #All interactions, dertivitave of full_network for ease
    @@full_interactions = []
    @@multi_gene_list = {1=> Set[],
                        2 => Set[],
                        3 => Set[],
                        4 => Set[],
                        5 => Set[]
                    }
    @@number_significant_components = 0

    def initialize(depth=3, gene_list=nil)
        

        # Input: Depth= number of neighbors to search, for example depth=2 searches interactions from
        # proteins in the gene_list, then searches interactions of those hits.

        # Output: a hash containing significant interactions between the gene
        # list as @@significant_paths where keys = [geneA, geneB] and values = 
        # [dijkstra_shortest_path from A to B]

        # This class definition for an object that is used to find interactions between genes.
        # The initialize method takes two arguments, depth and gene_list, and sets default values
        # for these arguments if they are not provided when the object is created.

        # The method then calls the find_first_interactors method on the gene_list argument, 
        # passing in a value of 1 for the second argument. This is followed by a loop that calls
        # the find_first_interactors method again, but this time with the @@multi_gene_list array 
        # and the current loop iteration as arguments.

        # Next, the code iterates over the @@full_interactions array and adds each edge to the 
        # @@full_network object, setting the edge weight to 1. It then creates an array of connected
        # components in the network, and loops over these components to find any that contain the seed genes.

        # For each component that contains seed genes, the code uses the combination method 
        # to find all possible pairs of genes, and then uses the dijkstra_shortest_path method 
        # to find the shortest path between these pairs. If the length of the path is less than or equal 
        # to 4, the path is added to the @@significant_paths hash with the gene pair as the key and the 
        # path as the value. 

        self.find_first_interactors(gene_list, 1)
        (2..depth).each do |i|
            self.find_first_interactors(@@multi_gene_list[i], i)
        end

        @@full_interactions.each do |query|
            query.each do |edge|
                source, target = edge.split("<->")
                @@full_network.add_edge(source, target)
                @@edge_weights[[source, target]] = 1
            end
        end
        
        seed_genes = @@multi_gene_list[1].to_a.flatten
        
        connected_components = []

        @@full_network.to_undirected.each_connected_component { |c| connected_components <<  c }
        
        connected_components.each do |component|
            if (component & seed_genes).any?
                @@number_significant_components += 1
                hits = component & seed_genes
                hits.combination(2).to_a.each do |hit|
                    source, target =  hit[0..1]
                    path = @@full_network.dijkstra_shortest_path(@@edge_weights, source=source, target=target)
                    
                    if path.length <= 4
                        @@significant_paths[[source, target]] = path.join("<->")
                        

                    end
                end
            end
        end
        puts  "#{@@number_significant_components} significant components"
    end

    def find_first_interactors(gene_list, current_degree)
        
        # find_first_interactors(gene_list, current_degree)

        # This function code is defining a method called "find_first_interactors"
        # that takes in two arguments: a list of genes (gene_list) and a current degree (current_degree).
        # The method initializes an empty list called "first_degree_hits" and calculates the
        # length of the gene list. It then prints a string that includes the current degree 
        # and the length of the search.

        # The code then iterates through the gene list and adds each gene to the 
        # "@@multi_gene_list" at the current degree. It then searches for interactions
        # with the first gene in the list and appends any hits to the "@@full_interactions" list.
        # If there are any hits, it adds the target of the edge to the "@@multi_gene_list" at the next degree.

        # This method searches for first degree interactions between genes in a given list and 
        # adding them to a list of interactions.
       
        
        first_degree_hits = []
        length_search = gene_list.length
        puts "Searching #{current_degree} degree neighbors.... O(#{length_search}^2)"
        gene_list.each do |query|
            @@multi_gene_list[current_degree].add(query)
            query_hits = self.find_interactions(query[0])
            unless query_hits.empty?
                @@full_interactions.append(query_hits)

            end

            query_hits.each do |edge|
                source, target = edge.split("<->")
                @@multi_gene_list[current_degree+1].add([target])
                
            end
        end 
    end

    def find_interactions(gene_id=@gene_id)
        
        # Input: Gene_id, a specfific gene ID from EBI

        # Output: Valid filtered protein-protein interactions of query gene

        # find_interactions defines a method called find_interactions that takes in a parameter gene_id,
        # which is assigned the value of the instance variable @gene_id by default. The method first 
        # fetches data from EBI url, and then checks if the data is valid. If it is, the data is split
        # into an array of lines and stored in a variable called interaction25 which is a tab25 format.

        # The code then iterates through each line of interaction25 and splits it into an array of elements,
        # which are then assigned to variables. The method then filters out unwanted interactions based on 
        # certain conditions, such as if the genes are from different organisms or if the interaction is of
        # low quality.

        # If the conditions are met, the method appends the interactions to an array called interactions,
        # and then returns this array at the end of the method.
        
        res = fetch(url: "http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{gene_id}?format=tab25");
        if res 
            interaction25 = res.body().split(/\n/)
            #puts interactions[0]
            interactions = []
            interaction25.each do |interact|
                
                line = interact.split(/\t/)
                #puts line[0].tr("uniprotkb:", '')
                ens_geneA = line[2].split(/\|/).grep(/^ensembl/)[0].to_s.tr("ensemblplants:", '') #3rd element is geneA, grep the ensemble plant ID
                ens_geneB = line[3].split(/\|/).grep(/^ensembl/)[0].to_s.tr("ensemblplants:", '') #4rd element is geneA, grep the ensemble plant ID

                organismA = line[9].split(/\|/).grep(/^taxid:3702\(arath\)/)
                organismB = line[10].split(/\|/).grep(/^taxid:3702\(arath\)/)
                
                quality = line[-1].split(/\|/).grep(/^intact-miscore/)[0][-3..-1].to_f
                #puts quality
                
                ens_geneA = ens_geneA.split(/\./)[0].to_s
                ens_geneB = ens_geneB.split(/\./)[0].to_s

                #Throwaway cases

                # GeneA is GeneB, end the loop ?

                next if ens_geneA.upcase == ens_geneB.upcase

                #GeneA and B are from different organisms
                next if organismA != organismB

                #Interaction is low quality
                next if quality < 0.55
      
                #Ens code not found for gene a or b
                next if ens_geneA.empty? or ens_geneB.empty?

                # Case 1: Query gene is gene A
                if ens_geneA.upcase == gene_id.upcase
                    #puts "Gene A is query"
                    interactions.append([ens_geneA, ens_geneB].join('<->'))
                end
                # Case 2: Query gene is gene B
                if ens_geneB.upcase == gene_id.upcase
                    #puts "Gene B is query"
                    interactions.append([ens_geneB, ens_geneA].join('<->'))
                end
                #interactions.append([ens_geneA, ens_geneB].join(','))

            end

            #@@full_interactions.append(interactions)
            return(interactions)
        end
            #puts interactions[0].split(/\t/)
        #gene_info[gene_id]  = data[0]
        
    end

    def self.full_interactions
        @@full_interactions
    end

    def self.full_network
        @@full_network
    end

    def self.multi_gene_list
        @@multi_gene_list
    end

    def self.significant_paths
        @@significant_paths
    end

    def self.number_significant_components
        @@number_significant_components
    end

end
