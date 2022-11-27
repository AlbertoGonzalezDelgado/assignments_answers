# Creating Objects
**Adrián Barreno Sánchez (adrian.barreno@alumnos.upm.es), Pablo Mata Aroco (p.mata@alumnos.upm.es), Alberto González Delgado (alberto.gondelgado@alumnos.upm.es)**

## What is Intensive Integration?

Creating Objects is a computer program designed in ruby to searching for interactions between genes and creating a interaction newtork. In addition, the program will search for GO and KEGG annotation of these genes and it will be saved both interaction network and annotations into a file.

## How to run Intensive Integration?
Download the code as [README file for assignment answers](../README.md) indicates. 

## Usage

To run the program, execute the following command (inside intensive_integration/ folder), adding the arguments recquired:

```
cd assignments_answers/intensive_integration/
```
```
ruby .rb <genes_file> <output_file> <argument3> <argument4> 
```
**Arguments:**
1. **[Genes_file:](documents/ArabidopsisSubNetwork_GeneList.txt)** file that provides a list of target genes that will be used for searching for interactions and annotations.
2. **[:](documents/)** file .
3. **[:](files/)** file 
4. **Output_file**: file where the report will be saved. There is an example of how it looks like [here](documents/)

To run the program using the files contained in [files folder](documents/), just execute the following command:
```
ruby .rb ./documents/ArabidopsisSubNetwork_GeneList.txt ./documents/ ./documents/
```
If output pathway specified already exists, the program will ask you if you want to overwrite it. Y/y (yes) or N/n (no) input is expected.



## Output
The output is verbose, it will be saved into a output file.
