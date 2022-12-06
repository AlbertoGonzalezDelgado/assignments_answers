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

    def initialize(depth=1, gene_list=nil)
        
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
