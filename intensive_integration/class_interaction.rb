#Creating an Interaction Network Object to contain the members of each network
require 'rest-client'
class InteractionNetwork
    atrr_accesor :gene_id_1
    atrr_accesor :gene_id_2
    atrr_accesor :relations
    atrr_accesor :gene_subn

    def initialize(gene_id_1:, gene_id_2: ,relations:)
        @gene_id_1 = gene_id_1
        @gene_id_2 = gene_id_2
        @relations = relations 
    end


    def find_interactions(gene_subn: , filepath:)
        subnet = File.read(:filepath)
        Interactions = Array.new #Creating an empty array to save interactions
        #https://code-maven.com/how-to-convert-a-string-to-uppercase-or-lowercase-in-ruby
        gene_subn=gene_gene_sub.upcase #When comparing I find more usefull upcase or low case the name because the format may be different
        return subnet
    end


#InteractionNetwork.acces_info(https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id= , At3g54340)