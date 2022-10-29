require csv

class Cross_data
    atrr_accesor :parent1
    atrr_accesor :parent2
    atrr_accesor :F2_Wild
    atrr_accesor :F2_P1
    atrr_accesor :F2_P2
    atrr_accesor :F2_P1P2
    atrr_reader :parent1 , :parent2 , :F2_Wild , :F2_P1 , :F2_P2 , :F2_P1P2

    def initialize (parent1, parent2, F2_Wild, F2_P1,F2_P2,F2_P1P2)
        @parent1 = parent1
        @parent = parent2
        @F2_Wild = F2_Wild
        @F2_P1 = F2_P1
        @F2_P2 = F2_P2
        @F2_P1P2 = F2_P1P2
    end
end

 #Empty array for saving data
 #file_path="files/cross_data.fsv"
 data_cross=[] 
 CSV.foreach("files/cross_data.fsv") do |row| # Iterar línea o fila por fila
cross_data.push Cross_data.new(row0], row[1], row[2], row[3],row[4],row[5])
