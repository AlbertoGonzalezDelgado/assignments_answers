#Importing required library and class
require_relative './class_seed_stock.rb'
require 'csv'

class StockDB
#Defining atribute accessors
  attr_accessor :table
  attr_accessor :headers
  attr_accessor :filepath
  attr_accessor :seed_stock_data
  
  #Defining initializer
  def initialize()
  end

  #Defining a method to import data from file
  def load_from_file(filepath:)
    unless File.file?(filepath)
      return ("File #{filepath} doesn't exist")
    else
      @table = CSV.read(File.open(filepath), headers: true, col_sep: "\t") # Importing stockfile as table
      @filepath = filepath          # Seed_stock_data.tsv path
      @seed_stock_data = Array.new  ## Empty array created to append gene objects.
      @headers = @table.headers

      # Conversion of seed stock into SeedStock objects
      @table.each do |data|
        seed_stock_object = SeedStock.new(seed_stock: data[0], mutant_gene_id: data[1], last_planted: data[2],
        storage: data[3], grams_remaining: data[4])
        @seed_stock_data << seed_stock_object
      end
      return @seed_stock_data
    end 
  end

  def get_SeedStock(id:)
    seed_stock = @seed_stock_data.select{|stock| stock.mutant_gene_id == id.to_s}
    return seed_stock[0]
  end

  def plant_seeds(grams:)
    @table.each do |row|                      # Iterating over each row
      row[4] = (row[4].to_i - grams.to_i)     # Substraction from Grams_Remaining
      if row[4] <= 0                          # return error message if value equal or < 0
        row[4] = 0
        $stderr.puts "WARNING: we have run out of Seed Stock #{row[0]}"
      end
    end
    return @table
  end

#Creating file to save new data after planting
#https://stackoverflow.com/questions/4822422/output-array-to-csv-in-ruby  

  def new_database(new_db:)           
    CSV.open("#{new_db}", 'w', col_sep: "\t") do |tsv| 
      tsv << @table.headers
      @table.each do |row|
        tsv << row
      end
    end
  end

'''
  seed_stock_db = StockDB.new
  seed_stock_db.load_from_file(filepath: "./files/seed_stock_data.tsv")

  print seed_stock_db.get_SeedStock(id: "AT1G30950")
  print ''
  print ''

  print seed_stock_db.plant_seeds(grams: 9)
  seed_stock_db.new_database(new_db: "./files/output.tsv")
'''
end

