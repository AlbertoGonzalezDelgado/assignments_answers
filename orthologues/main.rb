require 'bio'
'''
#Checking the number of inputs
unless ARGV.length == 2
    abort("FATAL ERROR: Files pathways are required. \nHELP MESSAGE: Check README.md for more information.")
end

#Checking if the files pathways are well specified
ARGV[0..1].each do |arg|
    unless File.file?(arg)
       abort("FATAL ERROR: File #{arg} does not exist or the pathway provided is not correct.")
    end
end

#Checking if the files pathways are not the same
if ARGV[0] == ARGV[1]
    abort("FATAL ERROR: You have provided the same pathway twice!")
end

#Checking if the files specified have fasta format
#Source: https://es.wikipedia.org/wiki/Formato_FASTA
ARGV[0..1].each do |arg|'''
#    if arg.split('.')[-1]!='fasta' && arg.split('.')[-1]!='fa'  && arg.split('.')[-1]!='ffn' && arg.split('.')[-1]!='fna' && arg.split('.')[-1]!='faa' && arg.split('.')[-1]!='frn'    
#       abort("FATAL ERROR: File #{arg} has not fasta format")
#    end
#end

puts ''
puts 'The files are being imported sucesfully'
puts ''
sleep 0.5
puts "Searching for orthologues between Arabidopsis and S. pombe"
puts ''
puts ''

################################# RECIPROCAL BEST HIT ##########################################

# Set the database paths for Arabidopsis and S. pombe
arabidopsis_db_path =  ARGV[0]
spombe_db_path =  ARGV[1]

# Create a BLAST factory for each species
#system("makeblastdb -in files/TAIR10_cds_20101214_updated.fa -dbtype 'prot' -out databases/TAIR 2> /dev/null")
#system("makeblastdb -in files/pep.fa -dbtype 'prot' -out databases/spombe 2> /dev/null")

arabidopsis_factory = Bio::Blast.local('blastp', arabidopsis_db_path, "-F ‘m S’ -s T")
spombe_factory = Bio::Blast.local('blastp', spombe_db_path, "-F ‘m S’ -s T")

# Read the Arabidopsis and S. pombe sequences from fasta files
arabidopsis_fasta = Bio::FlatFile.auto(ARGV[2])
spombe_fasta = Bio::FlatFile.auto(ARGV[3])

# Create a hash to store the reciprocal best hits
reciprocal_best_hits = {}


### ------------------ FIRST BLAST ------------------- ###
# Create a file to save the results of Arabidopsis BLAST on S. pombe genome.
first_blast = File.new("files/first_blast_unfiltered.txt", "w")
first_blast.write("query\ttarget\te-value\tidentity\toverlap\tquery_length\tbit-score\tquery_seq\ttarget_seq\n")

# Iterate over the Arabidopsis sequences 
arabidopsis_fasta.each_entry do |arabidopsis_seq|
  
  # BLAST the Arabidopsis sequence against the S. pombe database
  arabidopsis_results = spombe_factory.query(arabidopsis_seq)

  # Get the best hit from the BLAST results

  unless arabidopsis_results.hits.empty?
    
    # Print hits
    hit = arabidopsis_results.hits.first
    puts
    puts "#{arabidopsis_seq.entry_id} <==> #{hit.definition.split("|")[0]}"
    puts
    puts "Identity: #{hit.identity}\t e-value: #{hit.evalue}\t overlap: #{hit.identity}"
    puts
    puts hit.query_seq
    puts hit.target_seq
    puts
  
    # Save hits in file
    first_blast.write("#{arabidopsis_seq.entry_id}\t#{hit.definition.split("|")[0]}\t#{hit.evalue}\t#{hit.identity}\t#{hit.overlap}\t#{hit.query_len}\t#{hit.bit_score}\t#{hit.query_seq}\t#{hit.target_seq}\n")
  end
end

first_blast.close()

## We can now read the results of the first Blast
first_hits = Hash.new

File.readlines("files/first_blast_unfiltered.txt", chomp:true).each{ |hit|
  unless hit =~ /query/ # Skip header
    first_hits[hit.split("\t")[0]] = hit.split("\t")[1]
  end
}


### ----------------- SECOND BLAST ------------------ ###

# Create a file to save the resutls of the reciprocal blast.
second_blast = File.new("files/second_blast_unfiltered.txt", "w")
second_blast.write("query\ttarget\te-value\tidentity\toverlap\tquery_length\tbit-score\tquery_seq\ttarget_seq\n")

# We will only blast S. pombe sequences that are hits of the first blast
spombe_fasta.each_entry do |fasta|  
  if first_hits.values.include?(fasta.entry_id)
    
    #puts fasta.entry_id

    spombe_results = arabidopsis_factory.query(fasta)

    # Get the best hit from the BLAST results
    unless spombe_results.hits.empty?
              
      # Print hits
      hit = spombe_results.hits.first
      puts
      puts "#{fasta.entry_id} <==> #{hit.definition.split("|")[0]}"
      puts
      puts "Identity: #{hit.identity}\t e-value: #{hit.evalue}\t overlap: #{hit.identity}"
      puts
      puts hit.query_seq
      puts hit.target_seq
      puts
      puts
    
      # Save hits in file
      second_blast.write("#{fasta.entry_id}\t#{hit.definition.split("|")[0]}\t#{hit.evalue}\t#{hit.identity}\t#{hit.overlap}\t#{hit.query_len}\t#{hit.bit_score}\t#{hit.query_seq}\t#{hit.target_seq}\n")
    end
  end
end

second_blast.close()


'''
# BLAST the S. pombe sequence of the best hit against the Arabidopsis database
spombe_seq = Bio::FastaFormat.new(best_hit.accession)
spombe_results = spombe_factory.query(spombe_seq)

# Check if the Arabidopsis sequence of the best hit is the reciprocal best hit
reciprocal_best_hit = spombe_results.hits.first.accession == arabidopsis_seq.accession

# If the best hit is reciprocal, store the pair in the hash
if reciprocal_best_hit
  reciprocal_best_hits[arabidopsis_seq.accession] = best_hit.accession
end'''
'''
# Print the orthologue pairs
reciprocal_best_hits.each do |arabidopsis, spombe|
  puts "#{arabidopsis} => #{spombe}"
end
'''

#Source: https://www.asciiart.eu/computers/computers
puts ''
puts ''
puts "Analysis finished succesfully"
puts ''
puts ''
puts ' _______________                        |*\_/*|________'
puts '|  ___________  |     .-.     .-.      ||_/-\_|______  |'
puts '| |           | |    .****. .****.     | |           | |'
puts '| |   0   0   | |    .*****.*****.     | |   0   0   | |'
puts '| |     -     | |     .*********.      | |     -     | |'
puts '| |   \___/   | |      .*******.       | |   \___/   | |'
puts '| |___     ___| |       .*****.        | |___________| |'
puts '|_____|\_/|_____|        .***.         |_______________|'
puts '  _|__|/ \|_|_.............*.............._|________|_'
puts ' / ********** \                          / ********** \ '
puts '/  ************\                        /  ************\ '
puts '------------------                      -----------------'
puts