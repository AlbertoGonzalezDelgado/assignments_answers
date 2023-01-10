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
  if arg.split('.')[-1]!='fasta' && arg.split('.')[-1]!='fa'  && arg.split('.')[-1]!='ffn' && arg.split('.')[-1]!='fna' && arg.split('.')[-1]!='faa' && arg.split('.')[-1]!='frn'    
     abort("FATAL ERROR: File #{arg} is not Fasta format")
  end
end


### -------- LOAD FILES AND GENERATE DATABASES -------- ###

# Set the database paths for Arabidopsis and S. pombe
arabidopsis_db_path =  ARGV[0]
spombe_db_path =  ARGV[1]

# Create a BLAST factory for each species
#system("makeblastdb -in files/TAIR10_cds_20101214_updated.fa -dbtype 'prot' -out databases/TAIR 2> /dev/null")
#system("makeblastdb -in files/pep.fa -dbtype 'prot' -out databases/spombe 2> /dev/null")
arabidopsis_factory = Bio::Blast.local('tblastn', arabidopsis_db_path, "-F T")  # protein query nucleic database
spombe_factory = Bio::Blast.local('blastx', spombe_db_path, "-F T")             # nucleic query protein database

# Read the Arabidopsis and S. pombe sequences from fasta files
arabidopsis_fasta = Bio::FlatFile.auto(ARGV[2])
spombe_fasta = Bio::FlatFile.auto(ARGV[3])

puts ''
puts 'The files have being imported sucesfully'
puts ''
sleep 2
puts "Blasting Arabidopsis sequences on S. pombe proteome..."
puts ''


### ------------------ FIRST BLAST ------------------- ###

'''
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
'''

# We now retrieve the results of the first Blast into a new Hash
first_hits = Hash.new

File.readlines("files/first_blast_unfiltered.txt", chomp:true).each{ |hit|
  
  unless hit =~ /query/   # Skip header

    query = hit.split("\t")[0].strip
    target = hit.split("\t")[1].strip
    evalue = hit.split("\t")[2].strip.to_f
    perc_identity = 100 * (hit.split("\t")[3].strip.to_f) / (hit.split("\t")[7].length) # Identity / query sequence length
    puts perc_identity
    puts    
    if evalue <= 1e-10 && perc_identity >= 50                             # e-value < 1e-5 and identity > 50%
      first_hits[query] = target
    end
  end
}

puts
puts "BLAST of Arabidopsis sequences on S.pombe proteome is finished with a total number of #{first_hits.length} hits"
puts  
sleep 2
puts "Finding reciprocal best hits in Arabidopsis genome..."
puts
sleep 1


### ----------------- SECOND BLAST ------------------ ###

'''
# Create a file to save the unfiltered results of the reciprocal BLAST of S. pombe sequences on
# Arabidopsis genome.
second_blast = File.new("files/second_blast_unfiltered.txt", "w")
second_blast.write("query\ttarget\te-value\tidentity\toverlap\tquery_length\tbit-score\tquery_seq\ttarget_seq\n")

# We will only blast S. pombe sequences that are best hits of the first blast
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
'''

# We now retrieve the results of the second Blast into a new Hash applying identity filters.
second_hits = Hash.new

File.readlines("files/second_blast_unfiltered.txt", chomp:true).each{ |hit|
  unless hit =~ /query/   # Skip header

    query = hit.split("\t")[0].strip
    target = hit.split("\t")[1].strip
    evalue = hit.split("\t")[2].strip.to_f
    perc_identity = 100 * (hit.split("\t")[3].strip.to_f) / (hit.split("\t")[7].length) # Identity / query sequence length

    if evalue <= 1e-10 && perc_identity >= 50                             # # e-value < 1e-5 and identity > 50%
      second_hits[query] = target
      #puts query, target, evalue, perc_identity
    end
  end
}

puts
puts "Reciprocal BLAST of S.pombe sequences on Arabidopsis genome is finished with a total number of #{second_hits.length} hits"
puts  
sleep 2
puts "Finding reciprocal best hits in Arabidopsis proteome..."
puts
sleep 1


### ----------------- RECIPROCAL BEST HITS ------------------ ###

reciprocal_hits = Hash.new

first_hits.each do |key, value|
  if second_hits[value].eql?(key) then
    reciprocal_hits[key] = value
  end
end

reciprocal_report = File.new("files/reciprocal_best_hits.txt", "w")
reciprocal_report.write("A total number of #{reciprocal_hits.length} potential orthologs have been identified:\n\n")
reciprocal_hits.each { |arab, spombe|
  reciprocal_report.write("\t#{arab} <==> #{spombe}\n")
}
reciprocal_report.close


#Source: https://www.asciiart.eu/computers/computers
puts ''
puts ''
puts "Analysis finished succesfully!"
puts "A total number of #{reciprocal_hits.length} potential orthologs have been identified."
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
