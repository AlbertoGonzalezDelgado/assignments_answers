class Stockdatabase
  require 'csv'
  attr_accessor :table
  attr_accessor :headers
  attr_accessor :path
  attr_accessor :stockpath
  
  def initialize (stockpath:)
    unless File.file?(stockpath)
      return ("File doesn't exist")
    else
      @path = Dir.pwd # Current working directory
      @stockpath = stockpath # Seed_stock_data.tsv path
      @table = CSV.read(File.open(stockpath), headers: true, col_sep: "\t") # Importing stockfile as table
      @headers = table.headers
    end
  end



  def new_database (database)
    path = @path
    newstock = @table
    newstock.each { |row| #Iterating over each row
      row[4] = (row[4].to_i - 7) # Substraction of input from Grams_Remaining
      if row[4] <= 0 # return error message if value < 0
        row[4]=0
        $stderr.puts "WARNING: we have run out of Seed Stock #{row[0]}"
      end
    }
    CSV.open("#{path}/#{database}", 'w', col_sep: "\t") do |tsv| #Creating file to save new data in pwd
      tsv << newstock.headers
      newstock.each { |row| tsv << row }
    end
    return newstock
  end
  
  ["Seed_Stock", "Mutant_Gene_ID", "Last_Planted", "Storage", "Grams_Remaining"].each do |header|
    define_method "get_#{header}" do |match|
        col = @table[header]
        index = col.each_index.select{|x| col[x] == match}
        puts @headers.join(',')
        index.each { |i| puts "#{@table[i]}" }
        return
    end
  end
    
end

#Testing
#stock = Stockdatabase.new(stockpath: "/home/osboxes/bioinfogit/bioinfo_Chals/seed_stock_data.tsv")
#stock.get_Storage('cama25')
#puts stock.table
#puts stock.new_database('newstock.tsv')
#stock.headers
