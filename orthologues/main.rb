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




puts 'The files are being imported sucesfully'
puts ''
puts ''
sleep 1
puts "Searching for orthologues between Arabidopsis and S. pombe"
sleep 1
#Source: https://www.asciiart.eu/computers/computers
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

sleep 1

################################# CHECK FROM HERE ##########################################

# Set the database paths for Arabidopsis and S. pombe
arabidopsis_db_path =  ARGV[0]
spombe_db_path =  ARGV[1]

# Create a BLAST factory for each species
#system("makeblastdb -in files/pep.fa -dbtype 'prot' -out databases/spombe 2> /dev/null")

arabidopsis_factory = Bio::Blast.local('blastp', arabidopsis_db_path, "-F ‘m S’ -s T")
spombe_factory = Bio::Blast.local('blastp', spombe_db_path, "-F ‘m S’ -s T -e 1e-3")

# Read the Arabidopsis and S. pombe sequences from fasta files
arabidopsis_fasta = Bio::FlatFile.auto(ARGV[2])
spombe_fasta = Bio::FlatFile.auto(ARGV[3])

# Create a hash to store the reciprocal best hits
reciprocal_best_hits = {}

# Iterate over the Arabidopsis sequences
#arabidopsis_fasta.each_entry do |arabidopsis_seq|
 
arabidopsis_fasta.each_entry do |arabidopsis_seq|
  
  # BLAST the Arabidopsis sequence against the S. pombe database
  arabidopsis_results = spombe_factory.query(arabidopsis_seq)

  # Get the best hit from the BLAST results
  #best_hit = arabidopsis_results.hits.first

  unless arabidopsis_results.hits.empty?

    hit = arabidopsis_results.hits[0]

    puts hit.class
    puts
    puts "#{arabidopsis_seq.entry_id} <==> #{hit.definition.split("|")[0]}"
    puts
    puts "Identity: #{hit.identity}\t e-value: #{hit.evalue}"
    puts
    print arabidopsis_results.statistics
  
  end
  
end
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