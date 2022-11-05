# Creating Objects
**Adrián Barreno Sánchez (adrian.barreno@alumnos.upm.es), Pablo Mata Aroco (p.mata@alumnos.upm.es), Alberto González Delgado (alberto.gondelgado@alumnos.upm.es)**

## What is Creating Objects?

Creating Objects is a computer program designed in ruby to simulate planting 7g of seeds from a seed stock geneback, uptading the genebank information. In addition, the program is designed for proceesing the information and determinate which genes are genetically-linked. 

## How to install Creating Objects?
Download the code as [README file for assignment answers](../README.md) indicates. 

## Usage

To run the program, execute the following command (inside creating_objects/ folder), adding the arguments recquired:

```
cd assignment_answers/ruby_assignments/creating_objects/
```
```
ruby Proccessing.rb <seed_stock_data_file> <gene_information_file> <cross_data_file> <output> 
```
**Arguments:**
1. **[Seed stock data file:](files/seed_stock_data.tsv)** file where current information of the seed stock genebank is located.
2. **[Gene information file:](file/gene_information.tsv)** file where information of mutants phenotypes is included.
3. **[Cross data file:](file/cross_data.tsv)** file where the information of observed crossings is located
4. **Output**: file where the updated information of seed stock gene bank is saved after planting the seeds. An example of the report that could be helpful is contained [here](file/output_file.tsv)

To run the program using the files contained in [files folder](files/), just execute the following command:
```
ruby Proccessing.rb ./files/seed_stock_data.tsv ./files/gene_information.tsv ./files/cross_data.tsv ./files/new_stock_file.tsv  
```
If output pathway specified already exists, the program will ask you if you want to overwrite it. Y/y (yes) or N/n (no) input is expected.
Then, the program will ask you for the amount of seeds desired to plant.


## Output
The output is verbose, it will be printed in the standar output channel.

If some of the seeds from seed bank get out of stock, a Warning message indicating the seed stock name. In addition, the current status of the seed bank will be both printed and saved into output file.

The genes that are genetically linked will be also printed. The stadistics parameters used in this program corresponds to three degrees of freedom (Concept of Chi-Square Test | Genetics](https://www.yourarticlelibrary.com/fish/genetics-fish/concept-of-chi-square-test-genetics/88686)


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
10. https://learn.co/lessons/ruby-gets-input [05/11/2022]
