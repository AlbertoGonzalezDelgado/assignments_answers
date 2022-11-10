#Creating an Interaction Network Object to contain the members of each network
require 'rest-client'
class InteractionNetwork
    atrr_accesor :gene_id
    atrr_accesor :relations

    def initialize(gene_id:,relations:)
        @gene_id = :gene_id
        @relations = :relations 
    end

    def access_info(url_base: ,gene_id:)
        adress=puts "#{url_base}#{gene_id}"
end

#InteractionNetwork.acces_info(https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id= , At3g54340)

