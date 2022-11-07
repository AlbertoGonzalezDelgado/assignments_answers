class Stockdb
  require 'csv'
  attr_accessor :table
  attr_accessor :headers
  attr_accessor :stockpath
  attr_accessor :tsvtable
  
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

  def Stockdb.load_file(stockpath:)
    unless File.file?(stockpath)
      return ("File doesn't exist")
    else
      stock_array = CSV.read(File.open(stockpath), headers: true, col_sep: "\t") # Importing stockfile as table
      @path = Dir.pwd # Current working directory
      @stockpath = stockpath # Seed_stock_data.tsv path
      @table = stock_array
      stock_object_list = Array.new  ## Empty array created to append gene objects.

      # Conversion of genes into Gene objects
      stock_array.each do |data|
        stock_object = Stockdb.new(seed_stock: data[0], mutant_gene_id: data[1], last_planted: data[2],
        storage: data[3], grams_remaining: data[4])
        stock_object_list << stock_object
      end
      
      return stock_object_list
    end 
  end

  def Stockdb.new_database(stockpath:, newdb:, seeds:)
    @table = CSV.read(File.open(stockpath), headers: true, col_sep: "\t")
    newstock = @table
    newstock.each { |row| #Iterating over each row
      row[4] = (row[4].to_i - seeds.to_i) # Substraction from Grams_Remaining
      if row[4] <= 0 # return error message if value equal or < 0
        row[4]=0
        $stderr.puts "WARNING: we have run out of Seed Stock #{row[0]}"
      end
    }
    CSV.open("#{newdb}", 'w', col_sep: "\t") do |tsv| #Creating file to save new data in pwd
      tsv << newstock.headers #saving headers
      newstock.each { |row| tsv << row } #saving modified rows
    end
    return newstock
  end

end

