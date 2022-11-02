#gem install statistics2

require 'csv'
#require 'statistics2'

class Cross_data
    attr_accessor :parent1
    attr_accessor :parent2
    attr_accessor :f2_Wild
    attr_accessor :f2_P1
    attr_accessor :f2_P2
    attr_accessor :f2_P1P2

    def initialize(parent1:, parent2:, f2_Wild:, f2_P1:,f2_P2:,f2_P1P2:)
        @parent1 = parent1
        @parent2 = parent2
        @f2_Wild = f2_Wild
        @f2_P1 = f2_P1
        @f2_P2 = f2_P2
        @f2_P1P2 = f2_P1P2
    end

    def Cross_data.load_data(filepath:)
        unless File.file?(filepath)
            return("File does not exists")
        else
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

    #def get_chi_squared ()
    
    #Example code from Github: https://github.com/abscondment/statistics2/blob/master/test/sample_tbl.rb
    ##############################################################
        #def chi2_tbl(ln = nil, tn = nil)
        #    pers = [0.995, 0.99, 0.975, 0.95, 0.05, 0.025, 0.01, 0.005]
        #    arbi = (1..30).to_a + [40, 60, 80, 100]
        #   form = "  %7.5f"
        #    unless ln
        #      _printf("     "); pers.each do |a|; _printf(form, a); end;  _puts
         #   end
         ###########################################
    #end

end

print Cross_data.load_data(filepath: "./files/cross_data.tsv")
