#Importing required library
require 'csv'

class Genes
  #Defining atribute accessors an empty array
  attr_accessor :gene_ID
  attr_accessor :gene_name
  attr_accessor :mutant_phenotype
  @@gene_list = Array.new

  #Defining .new method with its properties and an object that will save all properties
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
  
  def linkage=(linkage)
    @linkage = linkage
  end

  def linkage
    return @linkage
  end

  #Defining a method to load data from file (specified in filepath).
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
#Defining a method to get all gene objects
  def Genes.all_genes
    return @@gene_list
  end

end
