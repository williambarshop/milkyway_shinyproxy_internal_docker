FROM r-base:3.3.3

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
    libxml2-dev \
    default-jre \
    default-jdk \
    git \
    librsvg2-dev \
    librsvg2-bin \
    libv8-3.14-dev
#    libssl1.0.0 \


# basic shiny functionality and a bunch of dependencies...
RUN R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cloud.r-project.org/')"
RUN R -e "install.packages(c('shinydashboard'), repos='https://cran.rstudio.com/')"
#RUN R -e "source('https://bioconductor.org/biocLite.R');biocLite(c('ggfortify'))"
#RUN R -e "install.packages(c('ggfortify'), repos='https://cran.rstudio.com/')"
RUN R -e "install.packages(c('httr','curl','RCurl','RColorBrewer','ggrepel','circlize','reshape2','plyr','splitstackshape','Hmisc','rPython','rsvg','magrittr','openxlsx','devtools','igraph','influenceR','visNetwork','ggfortify','rsvg','httr','shinyTree'), repos='https://cran.rstudio.com/',dependencies=TRUE)" && \
    R -e "library(devtools); install_version('DT',version='0.2',repos='http://cran.us.r-project.org')"
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

RUN wget https://cran.r-project.org/src/contrib/Archive/ggfortify/ggfortify_0.4.1.tar.gz ;\
    R -e "install.packages('ggfortify_0.4.1.tar.gz',type='source',repos=NULL)" ;\
    rm ggfortify_0.4.1.tar.gz


#The python side of the upload tool will require bioblend in python...
RUN pip install bioblend

#Now let's grab a copy of Milkyway (ShinyApp) from github to load into the image...
RUN mkdir /root/milkyway
#RUN echo '2018-01-29' && git clone https://github.com/heejongkim/MilkyWay_Frontend.git
RUN echo 'Image build from commit commit_rev and CI_job_ID on DATE-REPLACE' && git clone https://github.com/wohllab/MilkyWay_Frontend.git -b dev

#RUN find MilkyWay_Frontend/ -type f -print0 | xargs -0 sed -i 's/openms.bioinformatics.ucla.edu/milkyway-galaxy/g'
RUN find MilkyWay_Frontend/ -type f -print0 | xargs -0 sed -i 's/192.168.2.102/milkyway-galaxy/g'
RUN mv MilkyWay_Frontend/* /root/milkyway && rm -rf MilkyWay_Frontend && mv root/milkyway/Packages_from_Sources/* .

RUN R -e "install.packages('featureViewer.tar.gz',type='source',repos=NULL)"
RUN R -e "install.packages('sequenceViewer.tar.gz',type='source',repos=NULL)"
RUN R -e "install.packages('shinylorikeet.tar.gz',type='source',repos=NULL)"
RUN mkdir /root/milkyway/temp/ #This is necessary for the Excel report output

COPY Rprofile.site /usr/lib/R/etc/

EXPOSE 3838

CMD ["R", "-e shiny::runApp('/root/milkyway',port=3838,host='0.0.0.0')"]

