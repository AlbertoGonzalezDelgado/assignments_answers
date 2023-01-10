
Skip to content
Pull requests
Issues
Codespaces
Marketplace
Explore
@abarrenos
AlbertoGonzalezDelgado /
assignments_answers
Public

Fork your own copy of AlbertoGonzalezDelgado/assignments_answers

Code
Issues
Pull requests
Actions
Projects
Wiki
Security

    Insights

assignments_answers/orthologues/main.rb /
@Shettland
Shettland final changes
Latest commit cca6fd3 Jan 10, 2023
History
3 contributors
@abarrenos
@Shettland
@AlbertoGonzalezDelgado
189 lines (153 sloc) 6.93 KB
require 'bio'

#Checking the number of inputs
unless ARGV.length == 4
    abort("FATAL ERROR: BLAST databases and FASTA files paths are required.
      \nHELP MESSAGE: Check README.md for more information.")
end

#Checking if the files pathways are well specified
ARGV[0..1].each do |arg|
  unless File.file?(arg+".phr") || File.file?(arg+".nhr")
    abort("FATAL ERROR: Database #{arg} does not exist or the pathway provided is not correct.")
  end
end
ARGV[2..3].each do |arg|
  unless File.file?(arg)
    abort("FATAL ERROR: Fasta file #{arg} does not exist or the pathway provided is not correct.")
  end
end

#Checking if the files specified have fasta format
#Source: https://es.wikipedia.org/wiki/Formato_FASTA

ARGV[2..3].each do |arg|
  if arg.split('.')[-1]!="fasta" && arg.split('.')[-1]!="fa"  && arg.split('.')[-1]!="ffn" && arg.split('.')[-1]!="fna" && arg.split('.')[-1]!="faa" && arg.split('.')[-1]!="frn"    
     abort("FATAL ERROR: File #{arg} is not Fasta format")
  end
end

puts ''
puts "The files are being imported sucesfully"
puts ''
sleep 0.5
puts "BLASTing Arabidopsis sequences on S. pombe proteome..."
puts ''
puts ''

################################# RECIPROCAL BEST HIT ##########################################

# Set the database paths for Arabidopsis and S. pombe
arabidopsis_db_path =  ARGV[0]
spombe_db_path =  ARGV[1]

# Executing command from shell to create a blast database for each file
system("makeblastdb -in files/TAIR10_cds_20101214_updated.fa -dbtype 'nucl' -out #{arabidopsis_db_path} 2> /dev/null")
system("makeblastdb -in files/pep.fa -dbtype 'prot' -out #{spombe_db_path} 2> /dev/null")

# Create a BLAST factory for each species
arabidopsis_factory = Bio::Blast.local('tblastn', arabidopsis_db_path, "-F T")  # protein query nucleic database
spombe_factory = Bio::Blast.local('blastx', spombe_db_path, "-F T")             # nucleic query protein database

# Read the Arabidopsis and S. pombe sequences from fasta files
arabidopsis_fasta = Bio::FlatFile.auto(ARGV[2])
spombe_fasta = Bio::FlatFile.auto(ARGV[3])


### ------------------ FIRST BLAST ------------------- ###

# Create a file to save the unfiltered results of Arabidopsis BLAST on S. pombe genome. This
# way we can adjust data filtering a posteriori without needing to repeat the Blast.
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

# We now retrieve the results of the first Blast into a new Hash
first_hits = Hash.new

File.readlines("files/first_blast_unfiltered.txt", chomp:true).each{ |hit|
  unless hit =~ /query/ # Skip header
    first_hits[hit.split("\t")[0]] = hit.split("\t")[1]
  end
}

puts
puts "BLAST of Arabidopsis sequences on S.pombe proteome is finished with a total number of #{first_hits.length} hits"
puts  
sleep 1
puts "Finding reciprocal best hits in Arabidopsis proteome..."
puts

### ----------------- SECOND BLAST ------------------ ###

# Create a file to save the unfiltered results of the reciprocal BLAST of S. pombe sequences on
# Arabidopsis genome.
second_blast = File.new("files/second_blast_unfiltered.txt", "w")
second_blast.write("query\ttarget\te-value\tidentity\toverlap\tquery_length\tbit-score\tquery_seq\ttarget_seq\n")

# We will only blast S. pombe sequences that are best hits of the first blast to reduce computational cost
spombe_fasta.each_entry do |spombe_seq|  
  if first_hits.values.include?(spombe_seq.entry_id)
    
    spombe_results = arabidopsis_factory.query(spombe_seq)

    puts spombe_results.filtering

    # Get the best hit from the BLAST results
    unless spombe_results.hits.empty?
              
      # Print hits
      hit = spombe_results.hits.first
      puts
      puts "#{spombe_seq.entry_id} <==> #{hit.definition.split("|")[0]}"
      puts
      puts "Identity: #{hit.identity}\t e-value: #{hit.evalue}\t overlap: #{hit.identity}"
      puts
      puts hit.query_seq
      puts hit.target_seq
      puts
      puts
    
      # Save hits in file
      second_blast.write("#{spombe_seq.entry_id}\t#{hit.definition.split("|")[0]}\t#{hit.evalue}\t#{hit.identity}\t#{hit.overlap}\t#{hit.query_len}\t#{hit.bit_score}\t#{hit.query_seq}\t#{hit.target_seq}\n")
    end
  end
end

second_blast.close()

# We now retrieve the results of the second Blast into a list
hits_lines = File.readlines("files/second_blast_unfiltered.txt", chomp:true)

# Creating a second file to save the results after filter
filtered_blast = File.new("files/blast_results.txt", "w")

# Now we can filter based on identity% and e-value to ensure homology
hits_lines.each{ |hitt|
  # As bioruby's identity is not identity% we calculate it manually
  real_identity = (hitt.split("\t")[3].to_f / hitt.split("\t")[4].to_f) * 100
  unless hitt =~ /query/ # Skip header
    if hitt.split("\t")[2].to_f < 1e-5 && real_identity > 30
      #Then we save the results into a file
      filtered_blast.write(">#{hitt.split("\t")[0]}|#{hitt.split("\t")[1].chop}|")
      filtered_blast.write("#{hitt.split("\t")[2]}|#{real_identity}\n")
      filtered_blast.write("#{hitt.split("\t")[7]}\n#{hitt.split("\t")[8]}\n\n")
    end
  end
}

filtered_blast.close()
puts ""
puts ""
puts "Saving results into files/blast_results.txt"
sleep 1
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
Footer
© 2023 GitHub, Inc.
Footer navigation

    Terms
    Privacy
    Security
    Status
    Docs
    Contact GitHub
    Pricing
    API
    Training
    Blog
    About

assignments_answers/main.rb at main · AlbertoGonzalezDelgado/assignments_answers
