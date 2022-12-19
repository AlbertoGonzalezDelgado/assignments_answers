require './data_base.rb'
require 'csv'
require 'bio'


#Checking the number of inputs
unless ARGV.length == 3
    abort("FATAL ERROR: Files pathways are required. \nHELP MESSAGE: Check README.md for more information.")
end

#Checking if the files pathways are well specified
ARGV[0..2].each do |arg|
    unless File.file?(arg)
       abort("FATAL ERROR: File #{arg} does not exist or the pathway provided is not correct.")
    end
end

#Checking if the output files pathways are not the same
if ARGV[1] == ARGV[2]
    abort("FATAL ERROR: You have provided the same pathway twice for output file!")
end

#Checking if the output files already exists and asking if it should be overwrite

if File.file?(ARGV[1])
  puts "#{ARGV[1]} already exists, indicate if you want to overwrite [Y/N]" 
  stdin = ""
  until stdin == "n" || stdin == "N" || stdin == "y" || stdin == "Y"
      stdin = STDIN.gets.strip
      if stdin == "N" || stdin == "n"
          abort("Run cancelled")
      end
  end
end

#Checking if the output file already exists and asking if it should be overwrite

if File.file?(ARGV[2])
  puts "#{ARGV[2]} already exists, indicate if you want to overwrite [Y/N]" 
  stdin = ""
  until stdin == "n" || stdin == "N" || stdin == "y" || stdin == "Y"
      stdin = STDIN.gets.strip
      if stdin == "N" || stdin == "n"
          abort("Run cancelled")
      end
  end
end

puts('Loading files...')
sleep 1
gene_file_path = ARGV[0]

gene_list=Data_base.get_genelist(file_path: gene_file_path)

sequences_list=Array.new

exons_list=Array.new

genes_without = Set[]
gff_lines = Set[]
puts('Searching for cttctt in exons')
gene_list.each do |i|
    sequence=i[0]
    forward, reverse = Data_base.get_sequences(gene_id: sequence)

    if forward.empty? and reverse.empty?
        genes_without.add(sequence)
        
    else
        unless forward.empty?
            forward.each do |l|
                gff_lines.add(l)
            end
        end

        unless reverse.empty?
            reverse.each do |l|
                gff_lines.add(l)
            end
        end
    end
end

outfile = File.new(ARGV[1], "w+")

outfile.write("##GFF3\n")
gff_lines.each do |i|
  outfile.write("#{i.join("\t")}\n")
end
outfile.close


p "GFF done succesfully"

outfile = File.new(ARGV[2], "w+")

outfile.write("##Final Report\n")

outfile.write("Out of #{gene_list.length} input genes, #{genes_without.length} did contain the cttctt motif in their exons\n")


genes_without.each do |i|
  outfile.write("#{i} contains no cttctt motif \n")
end
outfile.close

#Source: https://www.asciiart.eu/art-and-design/borders
puts' __| |____________________________________________| |__'
puts'(__   ____________________________________________   __)'
puts'   | |                                            | |'
puts'   | |                                            | |'
puts'   | |                                            | |'
puts'   | |        ANALYSIS DONE SUCCESSFULLY !!       | |'
puts'   | |                                            | |'
puts'   | |                                            | |'
puts' __| |___________________________________________| |__'
puts'(__   ____________________________________________   __)'
puts'   | |                                            | |'
