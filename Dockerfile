#SAMTOOLS
#FROM comics/samtools:1.3.1 as SAMTOOLS
# Make BWA and SAMTOOLS accessible
#RUN setenforce 0
#RUN chmod -R 777 /software/applications/
#RUN chmod -R 777 /software/applications/samtools/1.3.1/bin/samtools.pl

# BWA
#FROM comics/bwa:0.7.15 as BWA
# Make BWA and SAMTOOLS accessible
#RUN setenforce 0
#RUN chmod -R 777 /software/applications/
#RUN chmod -R 777 /software/applications/bwa/v0.7.15/bwa

# R base
FROM rocker/r-ver:3.4.0

MAINTAINER Jan Winter "jan.winter@dkfz.de"

# COPY BWA AND SAMMTOOLS
RUN \
    mkdir -p /opt/tools/ \
    chmod 777 /opt/tools
    
######## SAMTOOLS

MAINTAINER Ian Merrick <MerrickI@Cardiff.ac.uk>

##############################################################
# Dockerfile Version:   0.1
# Software:             samtools
# Software Version:     1.3.1
# Software Website:     https://github.com/samtools/samtools/
# Description:          samtools
##############################################################

ENV APP_NAME=samtools
ENV VERSION=1.5
ENV GIT=https://github.com/BenLangmead/samtools.git
ENV APPS=/opt/tools
ENV DEST=$APPS/$APP_NAME/
ENV PATH=$APPS/$APP_NAME/$VERSION/bin:$APPS/bcftools/$VERSION/bin:$PATH

RUN apt-get update

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
    htop \
    ghostscript \
    libtbb2

RUN apt-get install -y zlib1g-dev \
                   libncurses5-dev ; \
    wget https://github.com/samtools/htslib/archive/$VERSION.tar.gz -O /tmp/htslib-$VERSION.tar.gz; \
    wget https://github.com/samtools/samtools/archive/$VERSION.tar.gz -O /tmp/samtools-$VERSION.tar.gz; \
    wget https://github.com/samtools/bcftools/archive/$VERSION.tar.gz -O /tmp/bcftools-$VERSION.tar.gz; \
    #curl -L -o htslib-$VERSION.tar.gz https://github.com/samtools/htslib/archive/$VERSION.tar.gz ; \
    #curl -L -o samtools-$VERSION.tar.gz https://github.com/samtools/samtools/archive/$VERSION.tar.gz ; \
    #curl -L -o bcftools-$VERSION.tar.gz https://github.com/samtools/bcftools/archive/$VERSION.tar.gz ; \
    tar xzf /tmp/bcftools-$VERSION.tar.gz ; \ 
    tar xzf /tmp/htslib-$VERSION.tar.gz ; \ 
    tar xzf /tmp/samtools-$VERSION.tar.gz ; \
    rm -rf /tmp/bcftools-$VERSION.tar.gz ; \
    rm -rf /tmp/htslib-$VERSION.tar.gz ; \
    rm -rf /tmp/samtools-$VERSION.tar.gz ; \
    mv /tmp/htslib-$VERSION /tmp/htslib ; \ 
    cd /tmp/bcftools-$VERSION ; \
    make -j HTSDIR=../htslib ; \
    make prefix=$APPS/bcftools/$VERSION install ; \
    cd .. ; \
    cd /tmp/samtools-$VERSION ; \
    make -j HTSDIR=../htslib ; \
    make prefix=$APPS/$APP_NAME/$VERSION install ; \
    cd ../ ; \
    rm -rf /tmp/htslib /tmp/samtools-$VERSION /tmp/bcftools-$VERSION

# Add PATH
#RUN echo 'export PATH=/opt/tools/bcftools/$VERSION/:$PATH' >> /etc/profile
RUN echo 'export PATH=/opt/tools/samtools/$VERSION/:$PATH' >> /etc/profile
#RUN echo 'export PATH=/opt/tools/htslib/$VERSION/:$PATH' >> /etc/profile


########## BWA

MAINTAINER Ian Merrick <MerrickI@Cardiff.ac.uk>

##############################################################
# Software:             bwa
# Software Version:     0.7.15
# Software Website:     https://github.com/lh3/bwa.git
# Description:          Burrow-Wheeler Aligner for pairwise alignment between DNA sequences
##############################################################

ENV APP_NAME=bwa
ENV VERSION=v0.7.15
ENV GIT=https://github.com/lh3/bwa.git
ENV DEST=/opt/tools/$APP_NAME/
ENV PATH=$DEST/$VERSION/:$DEST/$VERSION/bwakit:$PATH

RUN git clone $GIT ; \
    cd $APP_NAME ; \
    git checkout tags/$VERSION ; \
    make -j ; \
    mkdir -p /usr/share/licenses/$APP_NAME-$VERSION ; \
    cp COPYING /usr/share/licenses/$APP_NAME-$VERSION/ ; \
    rm -rf .git ; \
    cd ../ ;  \
    mkdir -p $DEST ; \
    mv $APP_NAME $DEST/$VERSION
    
#COPY --from=SAMTOOLS /software/applications/ /opt/tools
#COPY --from=BWA /software/applications/ /opt/tools
#ENV PATH=/opt/tools/bwa/v0.7.15:$PATH

# Add PATH
RUN echo 'export PATH=/opt/tools/bwa/v0.7.15/:$PATH' >> /etc/profile

#ENV PATH=/opt/tools/samtools/1.3.1/bin:$PATH
#RUN echo 'export PATH=/opt/tools/:$PATH' >> /etc/profile



#### things we need for the CRISPRVariantslite package
#### and another deb pkgs we later need for the R libraries to compile or run

# install the shiny server debian package from r-studio
RUN wget https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.5.3.838-amd64.deb -P /tmp/
#COPY ./shiny-server-1.5.2.837-amd64.deb /tmp/ss.deb
RUN gdebi -n /tmp/shiny-server-1.5.3.838-amd64.deb && \
    rm -f /tmp/shiny-server-1.5.3.838-amd64.deb

COPY ./shiny-server.sh /usr/bin/shiny-server.sh
RUN chmod +x /usr/bin/shiny-server.sh


# now to the R part...


# first we need devtools for all the installation of all further packages
RUN R -e 'install.packages("devtools", repos = "http://cloud.r-project.org/")'

# install all the packages we need from cran, bioconductor and github

RUN R -e 'source("http://bioconductor.org/biocLite.R");biocLite()'
RUN R -e 'source("http://bioconductor.org/biocLite.R");biocLite( c("CrispRVariants", "GenomicFeatures", "AnnotationDbi", "GenomicRanges","IRanges", "Rsamtools", "Biostrings") )'
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


# Downloaded repository from https://github.com/jwinter6/CrispRVariantsLite/
RUN mkdir /srv/shiny-server/CRISPRVariantsLite
RUN git clone https://github.com/jwinter6/CrispRVariantsLite.git /tmp/CRISPRVariantsLite
RUN cp -r /tmp/CRISPRVariantsLite/* /srv/shiny-server/CRISPRVariantsLite/


# add R profile options

RUN echo 'setwd("/srv/shiny-server/CRISPRVariantsLite")' >> /usr/local/lib/R/etc/Rprofile.site
RUN echo 'options(download.file.method = "libcurl")' >> /usr/local/lib/R/etc/Rprofile.site

# get BWA human reference genome
# will be added as symbolic link by providing a shared mount with the -v option
# see makefile in repository
# -v PATHTOGENOMES:/srv/shiny-server/CRISPRVariantsLite/genome/


# Make BWA and SAMTOOLS accessible
RUN chmod -R 777 /opt/tools/

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
RUN chmod +x /srv/shiny-server/index.html

EXPOSE 3838

# Add ENV for KiteMatic
ENV websockets_behind_proxy=FALSE
ENV verbose_logfiles=FALSE


ENTRYPOINT ["/docker-entrypoint.sh"]
# finally run
CMD ["crisprvariantslite"]
