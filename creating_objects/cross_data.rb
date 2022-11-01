require 'csv'

class Cross_data
    atrr_accesor :parent1
    atrr_accesor :parent2
    atrr_accesor :F2_Wild
    atrr_accesor :F2_P1
    atrr_accesor :F2_P2
    atrr_accesor :F2_P1P2
    atrr_reader :parent1 , :parent2 , :F2_Wild , :F2_P1 , :F2_P2 , :F2_P1P2

    def initialize (parent1:, parent2:, F2_Wild:, F2_P1:,F2_P2:,F2_P1P2:)
        @parent1 = parent1
        @parent = parent2
        @F2_Wild = F2_Wild
        @F2_P1 = F2_P1
        @F2_P2 = F2_P2
        @F2_P1P2 = F2_P1P2
    end

    def load_data
        data_cross=CSV.open("files/cross_data.rsv", col_sep= "\t", headers: true).read
        data_cross.each do |row|
            cross_object = Cross_data.new(  \
                parent1=row[0],\
                parent2=row[1],\
                F2_Wild=row[2],\
                F2_P1=row[3],\
                F2_P2=row[4], \
                F2_P1P2=row[5], \
        end
    end
end

print Cross_data.load_data(filepath: "./files/cross_data.tsv")
