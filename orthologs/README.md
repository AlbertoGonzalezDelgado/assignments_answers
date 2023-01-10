# Orthologues
**Adrián Barreno Sánchez (adrian.barreno@alumnos.upm.es), Pablo Mata Aroco (p.mata@alumnos.upm.es), Alberto González Delgado (alberto.gondelgado@alumnos.upm.es), Julian Elijah Politsch (julian.politsch@alumnos.upm.es), Angelo D'Angelo (angelo.dangelo@alumnos.upm.es)**


## What is Orthologues?

Orthologues is a computer program designed in ruby to search two fa representing the proteme of two related organisms and search for orthologs of species A to species B. Secondly, the script checks if the orrthologues are reciprocal by blasting species B to A. Those reciprical blast results are strong evidence of orthologous genes, but further methodology to prove orthology is outlined at the end of this document.

## How to run Orthologues?

Download the code as [README file for assignment answers](../README.md) indicates.

## BLAST options and filtering criteria

We performed bibliographic and webpage research to understand the function of different Blasting parameters. However, we realised that among all the different BLAST options described in the [NCBI webpage](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=BlastHelp), only a small subset of them can be "easily" customized in the BioRuby Blastall interface. These supported parameters can be found in the following webpage: [https://www.bioinformatics.org/ctls/wiki/Main/Blastall](https://www.bioinformatics.org/ctls/wiki/Main/Blastall).

After a quick search, we discovered that the filtering of low information sequence segments significantly affects the alignment scores and, therefore, optimises the election of best hits [[Wootton and Federhen (1996)](https://academic.oup.com/bioinformatics/article/24/3/319/252715?login=false)].For this reason, we decided to filter low-complexity sequences within out input query sequences with the option ("-F T"). Regions with low-complexity sequences -for instance, the protein sequence PPDPPPPPDKKKKDPPP- have an unusual poorly-variable composition that can create problems in sequence similarity search, artificially producing high hit scores [NCBI Webpage](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=BlastHelp). For our particular case (amino acid queries), we use the SEG method to identify and mask low-complexity regions [[Wootton & Federhen (1996)](https://www.sciencedirect.com/science/article/abs/pii/S0076687996660352?via%3Dihub)].

Besides filtering low-complexity sequences, we did not filter the hits obtained in the BLAST options. Instead, for each Blasting, we saved a report containing the best hit for every query sequence (without filtering) and hit information: e-value, identity, overlap, bit score and query and target sequences. Then we used these information to filter the Blast results a posteriori.


## Requirements:

* [BioRuby-Gem](https://rubygems.org/gems/bio-gem/versions/1.3.6)
```
gem install bio-gem
```
* [Fasta files](https://drive.google.com/drive/folders/0B7FLMiAz5IXPTWJDSkk1MTFPMjg?resourcekey=0-yhXCH6PxXIvg9xwMSolpMw)

* BLAST-formatted databases are created within the script

## Usage:

To run the program, execute the following command (inside orthologues/ folder), adding the arguments recquired:

```
cd assignments_answers/orthologues/
```
```
ruby main.rb <Arabidopsis_Database> <S_pombe_Database> <Arabidopsis.fa>  <S_pombe.fa>
```
**Arguments:**
1. **Arabidopsis_Database**
2. **S_pombe_Database**
3. **Arabidopsis.fa** 
4. **S_pombe.fa**

## Output
- blast_results.txt contains the results of the BLAST after quality filtering as well as other statistical information following the next format:
   >Query_ID|Target_ID|e-value|identity%
   - Query_sequence
   - Target_sequence

- Query_ID is the sequence ID in the S. pombe proteome.
- Target_ID is the ID of the sequence in the Arabidopsis genome
- e-value is the e-value of the blast hit between these two sequences.
- identity% is the percentaje of the sequences that are the same divided by the total length of the overlap

- Some other text files (first_blast.txt and second_blast.txt) will be generated in the process and can be used to obtain more info about each blast.

The command line output is verbose, some of which will be saved into a [output txt file](documents/). 

## Bonus Point:

There are several steps that can be taken to further analyze putative orthologues and confirm their orthology. We will outline the three that we have studied in other classes:

1. Compare the sequences of the suspected orthologues at a protein level. This can be done using a tool like the ClustalW, which aligns the amino acid sequences of the two proteins and calculates their degree of similarity. If the proteins are highly similar and the alignment is biologically meaningful, this is strong evidence that the genes are orthologues.

2. Compare the biological functions of the orthologous genes. While similar to point 1, if the genes contain functional notation it would be strong evidence or orthology. This information can be obtained by looking up the known functions of the genes in databases or by performing functional assays in a laboratory.

3. A third approach is to examine the evolutionary relationships by constructing a phylogenetic tree. This can be done by aligning the nucleotide or amino acid sequences of the genes from multiple organisms and using a method such as maximum likelihood to infer the evolutionary relationships between the sequences. If the two genes cluster together on the final trees, it is strong evidence of their orthology.

## References

* Gabriel Moreno-Hagelsieb, Kristen Latimer. (2008). Choosing BLAST options for better detection of orthologs as reciprocal best hits, Bioinformatics, Volume 24, Issue 3, 1, Pages 319–324. doi.org/10.1093/bioinformatics/btm585

* Wootton, J. C., & Federhen, S. (1996). Analysis of compositionally biased regions in sequence databases. Computer Methods for Macromolecular Sequence Analysis, 554–571. doi:10.1016/s0076-6879(96)66035-2

* NCBI Webpage


