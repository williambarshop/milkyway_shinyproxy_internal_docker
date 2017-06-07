FROM openanalytics/r-base

MAINTAINER William Barshop "wbarshop@ucla.edu"

# system libraries, etc
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.0.0 \
    libxml2-dev \
    default-jre \
    default-jdk \
    git \
    librsvg2-dev \
    librsvg2-bin \
    libv8-3.14-dev


# basic shiny functionality and a bunch of dependencies...
RUN R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cloud.r-project.org/')"
RUN R -e "install.packages(c('shinydashboard'), repos='https://cran.rstudio.com/')"
RUN R -e "install.packages(c('httr','curl','RCurl','DT','RColorBrewer','ggrepel','circlize','reshape2','plyr','splitstackshape','Hmisc','rPython','rsvg','magrittr','openxlsx','devtools','igraph','influenceR','visNetwork','ggfortify','rsvg','httr','shinyTree'), repos='https://cran.rstudio.com/',dependencies=TRUE)"
RUN R -e "source('https://bioconductor.org/biocLite.R');biocLite(c('ComplexHeatmap','NbClust','rhdf5'));install.packages(c('rhandsontable'))"

#Let's set up python and our R interconnection...
RUN apt-get install -y python-pip \
    python2.7 \
    python2.7-dev
RUN R -e "install.packages('rPython')"

#A few things we will have to manually grab and install....
RUN git clone https://github.com/scholtalbers/r-galaxy-connector.git;mv r-galaxy-connector/GalaxyConnector_0.3.tar.gz .
RUN R -e "install.packages('GalaxyConnector_0.3.tar.gz',type='source', repos=NULL)"
RUN wget https://github.com/rich-iannone/DiagrammeR/archive/v0.8.4.tar.gz
RUN R -e "install.packages('v0.8.4.tar.gz',type='source',repos=NULL)"
RUN R -e "install.packages(c('DiagrammeRsvg','data.table','UpSetR','cowplot','plotly','ggplot2'), repos='https://cran.rstudio.com/',dependencies=TRUE)"
#RUN R -e "devtools::install_github('ropensci/plotly')"
#RUN R -e "devtools::install_github('hadley/ggplot2')"

#The python side of the upload tool will require bioblend in python...
RUN pip install bioblend

#Now let's grab a copy of Milkyway (ShinyApp) from github to load into the image...
RUN mkdir /root/milkyway
RUN git clone https://github.com/heejongkim/MilkyWay_Frontend.git
RUN find MilkyWay_Frontend/ -type f -print0 | xargs -0 sed -i 's/openms.bioinformatics.ucla.edu/milkyway-galaxy/g'
RUN mv MilkyWay_Frontend/* /root/milkyway && rm -rf MilkyWay_Frontend && mv root/milkyway/Packages_from_Sources/* .

RUN R -e "install.packages('featureViewer.tar.gz',type='source',repos=NULL)"
RUN R -e "install.packages('sequenceViewer.tar.gz',type='source',repos=NULL)"
RUN R -e "install.packages('shinylorikeet.tar.gz',type='source',repos=NULL)"

COPY Rprofile.site /usr/lib/R/etc/

EXPOSE 3838

CMD ["R", "-e shiny::runApp('/root/milkyway',port=3838,host='0.0.0.0')"]

