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

# == InteractionNetwork
#
# InteractionNetwork class allows us to identify interactions between genes from an input gene list. 
# Interactors are fetched from Psiquic IntAct database and interaction networks are built using 
# We use Ruby Graph Library (RGL) framework to build interaction networks connecting previously
# identified interactors with a defined maximum network depth.
#
#
# == Summary
# 
# The initialize method takes two arguments, depth and gene_list, and sets default values
# for these arguments if they are not provided when the object is created.
# The method then calls the find_first_interactors method on the gene_list argument, 
# passing in a value of 1 for the second argument. This is followed by a loop that calls
# the find_first_interactors method again, but this time with the @@multi_gene_list array 
# and the current loop iteration as arguments.
#
# Next, the code iterates over the @@full_interactions array and adds each edge to the 
# @@full_network RGL::Adjacency Graph, setting the edge weight to 1. It then creates an array of connected
# components in the network, and loops over these components to find any that contain the seed genes.
# For each component that contains seed genes, the code uses the combination method 
# to find all possible pairs of genes, and then uses the dijkstra_shortest_path method 
# to find the shortest path between these pairs. If the length of the path is less than or equal 
# to 4, the path is added to the @@significant_paths hash with the gene pair as the key and the 
# path as the value. 

class InteractionNetwork
    
    """
    InteractionNetwork class takes as input a list of gene ID's and 
    creates a RGL adjacency network with uniform (1) edge weights.
    
    Result: a hash containing significant interactions between the gene
    list as @@significant_paths where keys = [geneA, geneB] and values = 
    [dijkstra_shortest_path from A to B]
    
    """
    # Return the list of genes involved in the interaction network.
    # @!attribute [rw]
    # @return [Array] The array of genes analysed
    attr_accessor :gene_list

    # All interaction networks instances generated, representing the full known network.
    @@full_network = RGL::AdjacencyGraph.new

    # Edge weights in our Adjacency Graph (default = 1).
    @@edge_weights = {}
    
    # Shortest path between pairs of genes, calculated using the dijkstra_shortest_path method.
    @@significant_paths = {}
    
    # All pairwise interactions between our query genes and their interactors fetched form IntAct database.
    @@full_interactions = []
    
    # Hash containing the interactors (values) at different depths (keys) for the query genes.
    @@multi_gene_list = {1=> Set[],
                        2 => Set[],
                        3 => Set[],
                        4 => Set[],
                        5 => Set[]
                    }
    # Number of significant (not empty) connected components in full interaction graph
    @@number_significant_components = 0

    # Create a new InteractionNetwork instance. Takes as input a list of gene ID's and creates a RGL adjacency network with uniform (1) edge weights.
    # @param depth [Integer] the maximum depth of the network. Consecutive neighboring nodes to be analysed.
    # @param gene_list [Array] an input array of genes
    # @return [InteractionNetwork] the gene interaction network instance. It generates, a hash containing significant interactions between the genes in the gene list named [@@significant_paths], where keys = [geneA, geneB] and values = shortest path from A to B]

    def initialize(depth=3, gene_list=nil)    

        #First degree
        self.find_first_interactors(gene_list, 1)
        
        #2nd + degree
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

    # This method searches for first degree interactions between genes in a given list and adding them to a list of interactions.
    # The method takes two arguments: a list of genes (gene_list) and a current degree (current_degree).
    # It initializes an empty list called "first_degree_hits" and calculates the
    # length of the gene list. It then prints a string that includes the current degree 
    # and the length of the search.
    #
    # The code then iterates through the gene list and adds each gene to the 
    # "@@multi_gene_list" at the current degree. It then searches for interactions
    # with the first gene in the list and appends any hits to the "@@full_interactions" list.
    # If there are any hits, it adds the target of the edge to the "@@multi_gene_list" at the next degree.
    #
    # @param gene_list [Array] an input array of genes
    # @param current_degree [Integer] the current depth at which the interactors are being indentified.
    # @return [void]

    def find_first_interactors(gene_list, current_degree)
                
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

    # Find gene-gene interactions from a particular gene_id, which is assigned the value of the instance variable @gene_id by default.
    # The method first fetches data from EBI url, and then checks if the data is valid. If it is, the data is split
    # into an array of lines and stored in a variable called interaction25 which is a tab25 format.
    #
    # The code then iterates through each line of interaction25 and splits it into an array of elements,
    # which are then assigned to variables. The method then filters out unwanted interactions based on 
    # certain conditions, such as if the genes are from different organisms or if the interaction is of
    # low quality.
    # If the conditions are met, the method appends the interactions to an array called interactions,
    # and then returns this array at the end of the method.
    # @param gene_id [String] a specfific gene ID from ENSEMBL
    # @return [Array] an interaction array containing filtered protein-protein interactions of query gene
    
    def find_interactions(gene_id=@gene_id)
        
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

    # Return all pairwise interactions between our query genes and their interactors fetched form IntAct database.
    # @return [Array] full record of pairwise interactions
    def self.full_interactions
        @@full_interactions
    end

    # Return full adjacency graph object containing all interactions (edges) between our query genes and their interactors
    # fetched from IntAct database. Each connected component is an independent gene interaction network.
    # @return [RGL::AdjacencyGraph] full interaction graph of our query genes.
    def self.full_network
        @@full_network
    end

    # Return a Hash containing the interactors (values) at different depths (keys) for the query genes in our input gene list.
    # @return [Hash] full interactions at different depths for our query genes.
    def self.multi_gene_list
        @@multi_gene_list
    end

    # Return the shortest path between these pairs of genes, calculated using the dijkstra_shortest_path method.
    # If the length of the path is larger than 4, the interaction network is not reproted.
    # @return [Hash] full interaction graph of our query genes.
    def self.significant_paths
        @@significant_paths
    end

    # Return number of significant (not empty) connected components in full interaction graph. Each connected component is an independent gene interaction network.
    # an independent gene interaction network.
    # @return [Integer] number of significant connected components in the interaction graph.
    def self.number_significant_components
        @@number_significant_components
    end

end
