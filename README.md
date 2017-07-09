## Introduction

This github repository contains the code underlying the *CrispRVariantsLite* Shiny-based web app, which accompanies the main [CrispRVariants](http://www.bioconductor.org/packages/CrispRVariants.html) package.  This web app is primarily available from the [Robinson lab](http://www.imls.uzh.ch/research/robinson.html) web server at [University of Zurich](http://www.uzh.ch/de.html) from the following link: [CrispRVariantsLite](http://imlspenticton.uzh.ch:3838/CrispRVariantsLite).  Instructions are given in the start up page of the app.

## Example data

Example ZIP files (and corresponding TXT files with description of genome location and/or guide+PAM sequence) for the different entry points can be found in the [/examples/](https://github.com/markrobinsonuzh/CrispRVariantsLite/tree/master/examples) directory.  If retrieving these files from the github repo, be sure to click on 'Raw' or 'View Raw'.

## Running this app locally

The CrispRVariantsLite web app can be run locally, after installation of the necessary R packages (see below) and well as the command line tools: [samtools](http://www.htslib.org/), [bwa mem](http://bio-bwa.sourceforge.net/) and the indices for the organism of interest. After all this is completed, clone a version of this repository, set up the symbolic links (see the [makelinks](https://github.com/markrobinsonuzh/CrispRVariantsLite/blob/master/makelinks) file) in the data/genome and data/txdb directories of the cloned repository and then the app can be run from the R console as:
```
    #install.packages("shiny")  # only needed if 'shiny' package is not already installed
    shiny::runApp( "/dir/to/CrispRVariantsLite/local/clone")
```
## Installing all the R packages

The following packages will be needed by the web app:
```
    source("https://bioconductor.org/biocLite.R")
    library(BiocInstaller)
    biocLite( c("CrispRVariants", "GenomicFeatures",
                "AnnotationDbi", "GenomicRanges",
                "IRanges", "Rsamtools", "Biostrings") )

    install.packages("ggplot2",quiet=TRUE)
    install.packages("shiny",quiet=TRUE)
    install.packages("shinydashboard",quiet=TRUE)
    install.packages("shinyBS",quiet=TRUE)
    install.packages("rhandsontable",quiet=TRUE)
```

## Other important details

The web application makes calls to bwa mem and samtools.  Therefore, for every organism of interest, a bwa index will need to be created from the genome sequence.  These need to be copied (or preferably, symbolically linked) to the data/genome directory; similarly, TxDb objects need to be saved to the data/txdb directory of the app.  The convention used is that all the files ending in .fa in the data/genome are presented to the user in the dropdown menu of the web application.  Importantly, the TxDB objects in the data/txdb directory must be named with the same prefix but a .sqlite extension.  That is, if you are working with the hg19 genome, the application is expecting hg19.fa (and hg19.fa.XXX for all the bwa indices) in the data/genome directory and hg19.sqlite in the data/txdb directory.


## Docker Container

Please download the latest docker container version via

```
docker pull boutroslab/crisprvariantslite:latest
```

In order to get the genome reference, create a folder on your machine and paste all necessary genome files (as described in the makelinks file) into this folder.

For the latest human genome, you can also follow these steps:

1. Download the genome reference build from UCSC
2. Run BWA to create an index

```
bwa index -a bwtsw GENOME.fa
```

3. Run SAMTOOLS to create an indexed FASTA

```
samtools faidx GENOME.fa
```

4. Create the txdb sqlite file

```
source("https://bioconductor.org/biocLite.R")
library(GenomicFeatures)

# e.g. for human genome hg38
txdb <- makeTxDbFromUCSC("hg38", "knownGene")

saveDb(txdb, file= "./genome/GENOME.sqlite")

```


## Starting the docker container

Dont forget to map the genome folder

docker run --rm -v PATHTOFOLDER:/srv/shiny-server/CRISPRVariantsLite/genome -p 3838:3838 boutroslab/crisprvariantslite:latest