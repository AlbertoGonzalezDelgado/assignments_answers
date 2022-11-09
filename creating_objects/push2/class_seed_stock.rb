require 'csv'

class SeedStock
  
  attr_accessor :seed_stock
  attr_accessor :mutant_gene_id
  attr_accessor :last_planted
  attr_accessor :storage
  attr_accessor :grams_remaining
  
  def initialize(seed_stock:, mutant_gene_id:, last_planted:, storage:, grams_remaining:)
      @seed_stock = seed_stock
      @mutant_gene_id = mutant_gene_id
      @last_planted = last_planted
      @storage = storage
      @grams_remaining = grams_remaining
  end
end


