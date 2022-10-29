require 'csv'

class Cross_data
    attr_accessor :parent1
    attr_accessor :parent2
    attr_accessor :f2_Wild
    attr_accessor :f2_P1
    attr_accessor :f2_P2
    attr_accessor :f2_P1P2
    attr_reader :parent1 , :parent2 , :f2_Wild , :f2_P1 , :f2_P2 , :f2_P1P2

    def initialize(parent1:, parent2:, f2_Wild:, f2_P1:,f2_P2:,f2_P1P2:)
        @parent1 = parent1
        @parent2 = parent2
        @f2_Wild = f2_Wild
        @f2_P1 = f2_P1
        @f2_P2 = f2_P2
        @f2_P1P2 = f2_P1P2
    end

    def Cross_data.load_data(filepath:)
        data_cross = CSV.open(filepath, col_sep: "\t", headers:true).read
        cross_object_list = Array.new
        
        data_cross.each do |row|
            cross_object = Cross_data.new(  \
                parent1: row[0],    \
                parent2: row[1],    \
                f2_Wild: row[2],    \
                f2_P1: row[3],      \
                f2_P2: row[4],      \
                f2_P1P2: row[5])
            cross_object_list << cross_object
        end
        return cross_object_list
    end
end

print Cross_data.load_data(filepath: "./files/cross_data.tsv")