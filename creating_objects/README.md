# Creating Objects
**Adrián Barreno Sánchez (adrian.barreno@alumnos.upm.es), Pablo Mata Aroco (p.mata@alumnos.upm.es), Alberto González Delgado (alberto.gondelgado@alumnos.upm.es)**

## What is Creating Objects?

Creating Objects is a computational pipeline designed in ruby to simulate planting 7g of seeds from a seed stock geneback, uptading the genebank information. In addition, the program is designed for proceesing the information and determinate which genes are genetically-linked. 

## How to install Creating Objects?

Crating objects requires the following dependency that should be installed previously:

* [statistics2](https://github.com/abscondment/statistics2)

Download the code from Github into the folder desired. For example: 
```
cd
mkdir creating_objects
cd creating_objects
git clone https://github.com/AlbertoGonzalezDelgado/ruby_assignments/tree/main/creating_objects

```


## Usage

To run the program, execute the following command, adding the arguments recquired:

```
ruby Proccessing.rb <seed_stock_data_file> <gene_information_file> <cross_data_file> <output> 
```
**Arguments:**
1. **Seed stock data file:** file where current information of the seed stock genebank is located.
2. **Gene information file:** file where information of mutants phenotypes is included.
3. **Cross data file**: file where the information of observed crossings is located
4. **Output**: file where the updated information of seed stock gene bank is saved after planting the seeds.

To run the program using the files contained in [files folder](files/), just execute the following command:
```
ruby Proccessing.rb ./files/seed_stock_data.tsv ./files/gene_information.tsv ./files/cross_data.tsv ./new_stock_file.tsv  
```
## Output


## References

1. https://parzibyte.me/blog/2019/02/09/leer-escribir-archivos-csv-ruby/ [30/10/2022]
2. https://stackoverflow.com/questions/28488422/how-to-check-the-number-of-arguments-passed-with-a-ruby-script [02/11/2022]
3. https://github.com/abscondment/statistics2/blob/master/test/sample_tbl.rb [02/11/2022]
4. https://www.toptal.com/ruby/ruby-metaprogramming-cooler-than-it-sounds [31/10/2022]
5. https://guides.rubygems.org/rubygems-basics/#installing-gems [02/11/2022]
6. https://www.honeybadger.io/blog/how-to-exit-a-ruby-program/ [28/10/2022]
7. https://code-maven.com/argv-the-command-line-arguments-in-ruby [01/11/2022]
8. https://www.yourarticlelibrary.com/fish/genetics-fish/concept-of-chi-square-test-genetics/88686 [04/11/2022]
9. https://www.biologydiscussion.com/wp-content/uploads/2016/12/clip_image038_thumb6-1.jpg [04/11/2022]
