#Creating an Interaction Network Object to contain the members of each network
class InteractionNetwork
    atrr_accesor :gene_id
    atrr_accesor :relations

    def initialize(gene_id:,relations:)
        @gene_id = :gene_id
        @relations = :relations 
    end
end
