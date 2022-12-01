require 'rest-client'
require_relative "fetch"
require "csv"
require "json"
require 'rgl/base'
require 'rgl/adjacency'
require 'rgl/connected_components'
require "rgl/implicit"

class InteractionNetwork
    
    attr_accessor :network, :gene_list

    #All networks of all objects called, representing the full known network
    @@full_network = RGL::AdjacencyGraph.new

    #All interactions, dertivitave of full_network for ease
    @@full_interactions = []
    @@multi_gene_list = {1=> Set[],
                        2 => Set[],
                        3 => Set[],
                        4 => Set[],
                        5 => Set[]
                    }

    def initialize(depth=1, gene_list=nil, network=nil)
        if depth == 1
            self.find_first_interactors(gene_list, 1)
            @@full_interactions.each do |query|
                query.each do |edge|
                    source, target = edge.split("<->")
                    @@full_network.add_edge(source, target)
                end
            end
        end 

        if depth == 2
            self.find_first_interactors(gene_list, 1)
            self.find_first_interactors(@@multi_gene_list[1], 2)

            @@full_interactions.each do |query|
                query.each do |edge|
                    source, target = edge.split("<->")
                    @@full_network.add_edge(source, target)
                end
            end
        end
        if depth == 3
            self.find_first_interactors(gene_list, 1)
            self.find_first_interactors(@@multi_gene_list[1], 2)
            self.find_first_interactors(@@multi_gene_list[2], 3)
            @@full_interactions.each do |query|
                query.each do |edge|
                    source, target = edge.split("<->")
                    @@full_network.add_edge(source, target)
                end
            end
        end

        if depth == 4
            self.find_first_interactors(gene_list, 1)
            self.find_first_interactors(@@multi_gene_list[1], 2)
            self.find_first_interactors(@@multi_gene_list[2], 3)
            self.find_first_interactors(@@multi_gene_list[3], 4)
            
            @@full_interactions.each do |query|
                query.each do |edge|
                    source, target = edge.split("<->")
                    @@full_network.add_edge(source, target)
                end
            end
        end
        
        

        seed_genes = @@multi_gene_list[1].to_a.flatten
        
        connected_components = []
        number_significant_components = 0

        @@full_network.to_undirected.each_connected_component { |c| connected_components <<  c }
        p connected_components.length
        connected_components.each do |component|
            if (component & seed_genes).any?
                number_significant_components += 1
                
                hits = component & seed_genes
                hits.each do |hit|
                    adjacent_vertices = @@full_network.adjacent_vertices(hit)
                    adjacent_vertices  = adjacent_vertices & seed_genes
                    if adjacent_vertices.any?
                        p "Connected component number #{number_significant_components}"
                        adjacent_vertices.each do |neighbor|  
                            p [hit, neighbor].join("<->")
                        end
                    end 
                end
            end
            
        end

=begin
        @@full_network.each_connected_component do |cc|
            puts cc
            puts "######"
            
        end
=end
    end

    def find_first_interactors(gene_list, current_degree)
        first_degree_hits = []
        puts "Searching #{current_degree} neighbors...."
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
                next if quality < 0.5
      
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

end