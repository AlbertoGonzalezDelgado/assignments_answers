class Stockdb
  require 'csv'
  attr_accessor :table
  attr_accessor :headers
  attr_accessor :path
  attr_accessor :stockpath
  attr_accessor :tsvtable
  
  def initialize (stockpath:)
    unless File.file?(stockpath)
      return ("File doesn't exist")
    else
      @path = Dir.pwd # Current working directory
      @stockpath = stockpath # Seed_stock_data.tsv path
      @table = CSV.read(File.open(stockpath), headers: true, col_sep: "\t") # Importing stockfile as table
      @headers = table.headers
      @tsvtable = CSV.parse(File.open(stockpath), headers: true) #tab separated table for data inspection
      
      table.headers.each do |header|
        define_singleton_method "get_#{header.downcase}" do |match| # Dinamycally declaring methods for each header 
            col = @table[header] 
            index = col.each_index.select{ |x| col[x] == match} #Selecting column indexes that match input
            puts @headers.join("\t") #printing headers to preserve table info
            index.each { |i| row = "#{@table[i]}" 
            row = row.gsub(",", "\t") # Selecting index's row and replacing , for tab
            puts row
            }
            return 
        end
      end
    end
  end

  def Stockdb.new_database (stockpath, newdb)
    @path = Dir.pwd
    @table = CSV.read(File.open(stockpath), headers: true, col_sep: "\t")
    newstock = @table
    newstock.each { |row| #Iterating over each row
      row[4] = (row[4].to_i - 7) # Substraction from Grams_Remaining
      if row[4] <= 0 # return error message if value equal or < 0
        row[4]=0
        $stderr.puts "WARNING: we have run out of Seed Stock #{row[0]}"
      end
    }
    CSV.open("#{@path}/#{newdb}", 'w', col_sep: "\t") do |tsv| #Creating file to save new data in pwd
      tsv << newstock.headers #saving headers
      newstock.each { |row| tsv << row } #saving modified rows
    end
    return newstock
  end
  
  #https://www.toptal.com/ruby/ruby-metaprogramming-cooler-than-it-sounds

end
