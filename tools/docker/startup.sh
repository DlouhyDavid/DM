#!/bin/bash

# spuštění aplikace R Shiny
R -e 'shiny::runApp("/srv/production/dm/R/web.R", port = 3838, host = "0.0.0.0")'