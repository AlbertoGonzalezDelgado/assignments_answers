class Stockdb
  require 'csv'
  attr_accessor :table
  attr_accessor :headers
  attr_accessor :path
  attr_accessor :stockpath
  attr_accessor :tsvtable
  
  attr_accessor :seed_stock
  attr_accessor :mutant_gene_id
  attr_accessor :last_planted
  attr_accessor :storage
  attr_accessor :grams_remaining
  
  def initialize (seed_stock:, mutant_gene_id:, last_planted:, storage:, grams_remaining:)
    unless 1==1 #File.file?(stockpath)
      return ("File doesn't exist")
    else
     # @path = Dir.pwd # Current working directory
     # @stockpath = stockpath # Seed_stock_data.tsv path
      #@table = CSV.read(File.open(stockpath), headers: true, col_sep: "\t") # Importing stockfile as table
      #@headers = table.headers
      #@tsvtable = CSV.parse(File.open(stockpath), headers: true) #tab separated table for data inspection
      
      @seed_stock = seed_stock
      @mutant_gene_id = mutant_gene_id
      @last_planted = last_planted
      @storage = storage
      @grams_remaining = grams_remaining
      
      #table.headers.each do |header|
       # define_singleton_method "get_#{header.downcase}" do |match| # Dinamycally declaring methods for each header 
        #    col = @table[header] 
         #   index = col.each_index.select{ |x| col[x] == match} #Selecting column indexes that match input
          #  puts @headers.join("\t") #printing headers to preserve table info
           # index.each { |i| row = "#{@table[i]}" 
            #row = row.gsub(",", "\t") # Selecting index's row and replacing , for tab
            #puts row
            #}
            #return 
        #end
      #end
    end
  end

  def new_database (database)
    path = @path
    newstock = @table
    newstock.each { |row| #Iterating over each row
      row[4] = (row[4].to_i - 7) # Substraction from Grams_Remaining
      if row[4] <= 0 # return error message if value equal or < 0
        row[4]=0
        $stderr.puts "WARNING: we have run out of Seed Stock #{row[0]}"
      end
    }
    CSV.open("#{path}/#{database}", 'w', col_sep: "\t") do |tsv| #Creating file to save new data in pwd
      tsv << newstock.headers #saving headers
      newstock.each { |row| tsv << row } #saving modified rows
    end
    return newstock
  end
  
  #https://www.toptal.com/ruby/ruby-metaprogramming-cooler-than-it-sounds
  
  def Stockdb.load_stock (stockpath:)
    unless File.file?(stockpath)                # Check if file exists
      return "This file path does not exist"
    else
      stock_array = CSV.open(stockpath, col_sep: "\t", headers:true).read
      stock_object_list = Array.new  ## Empty array created to append gene objects.

      # Conversion of genes into Gene objects
      stock_array.each do |stock|
        stock_object = Stockdb.new(seed_stock: stock[0],
          mutant_gene_id: stock[1],last_planted: stock[2], 
          storage: stock[3], grams_remaining: stock[4])
        stock_object_list << stock_object
      end
      return stock_object_list
    end
  end

end

#Testing
#stock = Stockdatabase.new(stockpath: "/home/osboxes/bioinfogit/bioinfo_Chals/seed_stock_data.tsv")
#stock.get_Storage('cama25')
#puts stock.table
#puts stock.new_database('newstock.tsv')
#stock.headers

#clases = Stockdb.load_stock(stockpath: "/home/osboxes/bioinfogit/bioinfo_Chals/seed_stock_data.tsv")
