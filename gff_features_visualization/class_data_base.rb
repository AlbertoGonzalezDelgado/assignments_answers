require 'csv'

class data_base
    atrr_accessor :gene_id
    atrr_accessor :filepath

    @@genelist=Array.new

    def initialize(gene_id: ,filepath:)
        @gene_id = gene_id
        @filepath = filepath
    end

    def get_genelist(file_path:)
        unless File.file?(file_path)
            abort("FATAL ERROR: File #{filepath} does not exist or the pathway specified is not correct")
        else 
            temp_file=CSV.read(gene_information, col_sep: "\t")
            temp_file.each do |line|
                unless line[0].match(/AT\dG\d{5}/i) # Ignoring case sensitive in match method https://stackoverflow.com/questions/41149008/case-insensitive-regex-matching-in-ruby
                    abort("ERROR: the gene list have some errors. #{line[0]} has not correct format")
                else
                  gene_list.append([line[0].upcase])
                
                end
            end
        end 

    end
end
