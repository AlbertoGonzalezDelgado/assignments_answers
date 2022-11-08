require 'csv'

class CrossData
    attr_accessor :parent1
    attr_accessor :parent2
    attr_accessor :f2_Wild
    attr_accessor :f2_P1
    attr_accessor :f2_P2
    attr_accessor :f2_P1P2
    @@cross_data_list = Array.new

  def initialize(parent1:,parent2:,f2_Wild:,f2_P1:,f2_P2:,f2_P1P2:)
    @parent1 = parent1
    @parent2 = parent2
    @f2_Wild = f2_Wild
    @f2_P1 = f2_P1
    @f2_P2 = f2_P2
    @f2_P1P2 = f2_P1P2
    @@cross_data_list << self
  end

  def CrossData.load_data(filepath:)
    data_cross = CSV.open(filepath, col_sep: "\t", headers:true).read    
    data_cross.each do |row|
      CrossData.new(  \
          parent1: row[0],    \
          parent2: row[1],    \
          f2_Wild: row[2],    \
          f2_P1: row[3],      \
          f2_P2: row[4],      \
          f2_P1P2: row[5])
    end
    return @@cross_data_list
  end
  
  def CrossData.get_linked(filepath:)

      cross_table = CSV.open(filepath, col_sep: "\t", headers:true).read
    
    cross_table.each do |row|
      total = 0
      row[2..cross_table.length()].each do |value|
        total = total + value.to_i
      end
  
      # Calculate expected frequencies
      exp_fw = (total/16)*9
      exp_fp1 = (total/16)*3
      exp_fp2 = (total/16)*3
      exp_fp12 = (total/16)
        
      # Real observations
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

        linked_cross = CrossData.load_data(filepath:filepath).select {|gene| gene.parent1 == row[0]}[0]
        return linked_cross, chi_sq
          
      end
    end
    
    #puts "Final Report:"
    #puts "#{linked[0]} is linked to #{linked[1]}"
    #puts "#{linked[1]} is linked to #{linked[0]}"
    #puts chi_sq.round(2)
  end

  '''
  print CrossData.load_data(filepath: "./files/cross_data.tsv")
  CrossData.get_linked(filepath: "files/cross_data.tsv")
'''

end