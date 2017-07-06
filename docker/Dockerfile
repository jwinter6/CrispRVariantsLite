FROM rocker/r-ver:3.4.0
FROM comics/samtools:latest # samtools
FROM comics/bwa:latest # BWA


MAINTAINER Jan Winter "jan.winter@dkfz.de"

#### things we need for the crispranalyzer package
#### and for the crispr reannotator
#### and another deb pkgs we later need for the R libraries to compile or run
RUN apt-get update && apt-get install -y  \
    wget \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    build-essential \
    libgd-dev \
    libexpat1-dev \
    libxml2-dev \
    git \
    libssl-dev \
    curl \
    libssl-dev \
    libtiff5-dev \
    htop
    
RUN apt-get update && apt-get install -y ghostscript

# again some more things we need to run the crispranalyzer package
RUN apt-get update && apt-get -y --no-install-recommends \
   install texlive texlive-xetex

# install the shiny server debian package from r-studio
COPY ./shiny-server-1.5.2.837-amd64.deb /tmp/ss.deb
RUN gdebi -n /tmp/ss.deb && \
    rm -f /tmp/ss.deb

COPY ./shiny-server.sh /usr/bin/shiny-server.sh
RUN chmod +x /usr/bin/shiny-server.sh

# now to the R part...


# first we need devtools for all the installation of all further packages
RUN R -e 'install.packages("devtools", repos = "http://cloud.r-project.org/")'

# install all the packages we need from cran, bioconductor and github

RUN R -e 'source("http://bioconductor.org/biocLite.R");biocLite()'
RUN R -e 'biocLite( c("CrispRVariants", "GenomicFeatures", "AnnotationDbi", "GenomicRanges","IRanges", "Rsamtools", "Biostrings") )'
RUN R -e 'devtools::install_version("dplyr", version = "0.5.0", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("readr", version = "1.0.0", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("shinydashboard", version = "0.5.3", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("tidyverse", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("shinyBS", version = "0.61", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("data.table", version = "1.10.4", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("httr", version = "1.2.1", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("rhandsontable", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("htmltools", version = "0.3.5", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("DT", version = "0.2", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("shinyjs", version = "0.9", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("ggplot2", version = "2.2.0", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("markdown", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("knitr", version = "1.15.1", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("shiny", version = "1.0.2", repos = "http://cloud.r-project.org/")'
RUN R -e 'devtools::install_version("bookdown", version = "0.3", repos = "http://cloud.r-project.org/")'




# cleaning up downloaded deb packages for keeping clean our docker image
RUN apt-get -qq clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# install caR (TODO: replace private gitlab repos with public github account later..)
RUN git clone git@github.com:jwinter6/CrispRVariantsLite.git /srv/shiny-server/CRISPRVariantsLite


# add R profile options

RUN echo 'setwd("/srv/shiny-server/CRISPRVariantsLite")' >> /usr/local/lib/R/etc/Rprofile.site
RUN echo 'options(download.file.method = "libcurl")' >> /usr/local/lib/R/etc/Rprofile.site

# get BWA human reference genome
# will be added as symbolic link by providing a shared mount with the -v option
# see makefile in repository
# /srv/shiny-server/CRISPRVariantsLite/reference/ SYMBOLIC LINKS


# MAKE BWA INDEX
# BW index also needs to be in /srv/shiny-server/CRISPRVariantsLite/reference/
# bwa index ref.fa


COPY docker-entrypoint.sh /
COPY index.html /srv/shiny-server
RUN chmod +x /docker-entrypoint.sh
RUN chmod +x /srv/shiny-server/index.html

EXPOSE 3838

# Add ENV for KiteMatic
ENV websockets_behind_proxy=FALSE
ENV verbose_logfiles=TRUE


ENTRYPOINT ["/docker-entrypoint.sh"]
# finally run
CMD ["crisprvariantslite"]
