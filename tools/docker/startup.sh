#!/bin/bash

# instalce balíků
R -e 'source("/srv/dm/R/init.R")'

# spuštění aplikace R Shiny
R -e 'shiny::runApp("/srv/dm/R/web.R")'