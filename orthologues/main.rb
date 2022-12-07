require 'bio'

# Set the database paths for Arabidopsis and S. pombe
arabidopsis_db_path = '/path/to/arabidopsis/database'
spombe_db_path = '/path/to/s.pombe/database'

# Create a BLAST factory for each species
arabidopsis_factory = Bio::Blast.local('blastn', arabidopsis_db_path)
spombe_factory = Bio::Blast.local('blastn', spombe_db_path)

# Read the Arabidopsis and S. pombe sequences from fasta files
arabidopsis_fasta = Bio::FastaFormat.open('arabidopsis.fasta')
spombe_fasta = Bio::FastaFormat.open('s.pombe.fasta')

# Create a hash to store the reciprocal best hits
reciprocal_best_hits = {}

# Iterate over the Arabidopsis sequences
arabidopsis_fasta.each do |arabidopsis_seq|
  # BLAST the Arabidopsis sequence against the S. pombe database
  arabidopsis_results = arabidopsis_factory.query(arabidopsis_seq)

  # Get the best hit from the BLAST results
  best_hit = arabidopsis_results.hits.first

  # BLAST the S. pombe sequence of the best hit against the Arabidopsis database
  spombe_seq = Bio::FastaFormat.new(best_hit.accession)
  spombe_results = spombe_factory.query(spombe_seq)

  # Check if the Arabidopsis sequence of the best hit is the reciprocal best hit
  reciprocal_best_hit = spombe_results.hits.first.accession == arabidopsis_seq.accession

  # If the best hit is reciprocal, store the pair in the hash
  if reciprocal_best_hit
    reciprocal_best_hits[arabidopsis_seq.accession] = best_hit.accession
  end
end

# Print the orthologue pairs
reciprocal_best_hits.each do |arabidopsis, spombe|
  puts "#{arabidopsis} => #{spombe}"
end
