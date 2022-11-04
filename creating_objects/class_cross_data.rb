require 'csv'

class Cross_data
    attr_accessor :parent1
    attr_accessor :parent2
    attr_accessor :f2_Wild
    attr_accessor :f2_P1
    attr_accessor :f2_P2
    attr_accessor :f2_P1P2

  def initialize(parent1:,parent2:,f2_Wild:,f2_P1:,f2_P2:,f2_P1P2:)
    @parent1 = parent1
    @parent2 = parent2
    @f2_Wild = f2_Wild
    @f2_P1 = f2_P1
    @f2_P2 = f2_P2
    @f2_P1P2 = f2_P1P2
  end

  def Cross_data.load_data(filepath:)
    data_cross = CSV.open(filepath, col_sep: "\t", headers:true).read
    cross_object_list = Array.new
    
    data_cross.each do |row|
      cross_object = Cross_data.new(  \
          parent1: row[0],    \
          parent2: row[1],    \
          f2_Wild: row[2],    \
          f2_P1: row[3],      \
          f2_P2: row[4],      \
          f2_P1P2: row[5])
      cross_object_list << cross_object
    end
    return cross_object_list
  end
  
  def Cross_data.linkage(filepath:)
    cross_table = CSV.open(filepath, col_sep: "\t", headers:true).read
    linked=[]
    cross_table.each do |row|
      total = 0
      row[2..cross_table.length()].each do |value|
        total = total + value.to_i
      end
      #expectancies
      exp_fw = (total/16)*9
      exp_fp1 = (total/16)*3
      exp_fp2 = (total/16)*3
      exp_fp12 = (total/16)
      
      #Calculating fractions
      fw = row[2].to_f
      fp1 = row[3].to_f
      fp2 = row[4].to_f
      fp12 = row[5].to_f
      
      # Calculating chi-square values
      # https://www.yourarticlelibrary.com/fish/genetics-fish/concept-of-chi-square-test-genetics/88686
      chi_sq = ((fw - exp_fw)**2)/exp_fw + \
               ((fp1 - exp_fp1)**2)/exp_fp1 + \
               ((fp2 - exp_fp2)**2)/exp_fp2 + \
               ((fp12 - exp_fp12)**2)/exp_fp12
      
      # P-value calculated for n-1 = 3 degrees of freedom
      if chi_sq > 7.82
        puts "X2 = #{chi_sq.round(2)}   (p value < 0.05)"
        print "genes #{row[0]} and #{row[1]} are linked\n\n"
        linked << row[0]
        linked << row[1]
      end
    end
    puts "Final Report:"
    puts "#{linked[0]} is linked to #{linked[1]}"
    puts "#{linked[1]} is linked to #{linked[0]}"
  end

end
