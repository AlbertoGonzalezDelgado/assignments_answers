class Seedstock
  require 'csv'
  attr_accessor :table
  attr_accessor :stockID
  attr_accessor :mutant
  attr_accessor :path
  
  def initialize (stockpath:)
    unless File.file?(stockpath)
      return ("File doesn't exist")
    else
      @path = Dir.pwd
      @stockpath = stockpath
      @stockID = stockID
      @mutant = mutant
      @table = CSV.read(File.open(stockpath), headers: true, col_sep: "\t")
    end
  end


  def seeding (seednum)
    path = @path
    newstock = @table
    newstock.each { |row| #Iterating over each row
      row[4] = (row[4].to_i - seednum) # Substraction of input from Grams_Remaining
      if row[4] <= 0 # return error message if value < 0
        row[4]=0
        $stderr.puts "WARNING: we have run out of Seed Stock #{row[0]}"
      end
    }
    CSV.open("#{path}/newstock.tsv", 'w', col_sep: "\t") do |tsv|
      tsv << newstock.headers
      newstock.each { |row| tsv << row }
    end
    return newstock
  end
  
  def linking (stockid, mut_gene)
    @stockID = stockid
    @mutant = mut_gene
  end
    
end
