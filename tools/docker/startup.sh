#!/bin/bash

# instalce balíků
R -e 'source("/workspaces/DM/R/init.R")'

# spuštění aplikace R Shiny
R -e 'shiny::runApp("web.R")'