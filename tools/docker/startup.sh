#!/bin/bash

# instalce balíků
R -e 'install.packages("shinythemes")'

# spuštění aplikace R Shiny
R -e 'shiny::runApp("/srv/dm/R/web.R")'