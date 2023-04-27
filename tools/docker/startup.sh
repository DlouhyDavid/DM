#!/bin/bash

# instalace balíčku shiny
Rscript -e "install.packages('shiny', repos='http://cran.rstudio.com/')"

# spuštění aplikace R Shiny
R -e 'shiny::runApp("/srv/dm/web.R", port = 3838, host = "0.0.0.0")'