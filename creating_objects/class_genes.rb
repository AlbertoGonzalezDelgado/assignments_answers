require 'csv'

class Genes
  attr_accessor :gene_ID
  attr_accessor :gene_name
  attr_accessor :mutant_phenotype
  
  def initialize(gene_ID:, gene_name:, mutant_phenotype:)
    @gene_ID = gene_ID
    @gene_name = gene_name
    @mutant_phenotype = mutant_phenotype
    
    # Checking if the gene format is correct
    unless gene_ID.match(/A[Tt]\d[Gg]\d\d\d\d\d/)
      abort("FATAL ERROR: #{gene_ID} format is not correct. The format should be /A[Tt]\d[Gg]\d\d\d\d\d/")
    end
  end
  
  def Genes.load_genes(filepath:)
    unless File.file?(filepath)                # Check if file exists
      return "This file path does not exist"
    else
      gene_array = CSV.open(filepath, col_sep: "\t", headers:true).read
      gene_object_list = Array.new  ## Empty array created to append gene objects.

      # Conversion of genes into Gene objects
      gene_array.each do |gene|
        gene_object = Genes.new(gene_ID: gene[0],gene_name: gene[1],mutant_phenotype: gene[2])
        gene_object_list << gene_object
      end
      return gene_object_list
    end 
  end
  '''
  Using CSV, we open the gene file and read it as a table format using read method. We iterate each row 
  create a Gene object for each gene, converting each feature of the tsv file into an instance attribute.
  '''
  #gene1 = Genes.new(gene_ID: "AT345213", gene_name:"Important gene", mutant_phenotype:"Example phenotype" )
  #puts gene1.gene_ID
  #puts gene1.gene_name
end
