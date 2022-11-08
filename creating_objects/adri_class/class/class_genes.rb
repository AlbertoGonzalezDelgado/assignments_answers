require 'csv'

class Genes
  attr_accessor :gene_ID
  attr_accessor :gene_name
  attr_accessor :mutant_phenotype
  @@gene_list = Array.new
  
  def initialize(gene_ID:, gene_name:, mutant_phenotype:)
    @gene_ID = gene_ID
    @gene_name = gene_name
    @mutant_phenotype = mutant_phenotype
    @@gene_list << self
    
    # Checking if the gene format is correct
    unless gene_ID.match(/A[Tt]\d[Gg]\d\d\d\d\d/)
      abort("FATAL ERROR: #{gene_ID} format is not correct. The format should be /A[Tt]\d[Gg]\d\d\d\d\d/")
    end
  end
  
  def Genes.load_data(filepath:)
    unless File.file?(filepath)                # Check if file exists
      return "This file path does not exist"
    else
      gene_table = CSV.open(filepath, col_sep: "\t", headers:true).read

      # Conversion of genes into Gene objects
      gene_table.each do |gene|
        Genes.new(gene_ID: gene[0],gene_name: gene[1],mutant_phenotype: gene[2])
      end
      return @@gene_list
    end 
  end

  def Genes.all_genes
    return @@gene_list
  end

'''
  print Genes.all_genes
  Genes.load_data(filepath: "./files/gene_information.tsv")
  print Genes.all_genes
'''
end
