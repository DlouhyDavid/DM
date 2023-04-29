# Instalace balíčku shinythemes pro použití předpřipravených témat
install.packages("shinythemes")
library(shiny)
library(shinythemes)

# UI rozhraní s použitím tema "Flatly" z balíčku shinythemes
ui <- fluidPage(
  theme = shinytheme("flatly"), # Použití tématu "Flatly"
  tags$head(
    # Vlastní CSS styly vložené pomocí tagu <style>
    tags$style(HTML("
      /* Stylování vstupních políček */
      .form-group input[type='number'] {
        border: none;
        background-color: #f2f2f2;
        padding: 10px 15px;
        border-radius: 5px;
        margin-right: 10px;
        font-size: 1.2rem;
      }

      /* Stylování tlačítek */
      .btn-default {
        background-color: #337ab7;
        color: #fff;
        border: none;
        border-radius: 5px;
        padding: 10px 20px;
        font-size: 1.2rem;
      }

      /* Stylování výstupního pole */
      .shiny-text-output {
        font-size: 1.5rem;
        margin-top: 20px;
      }
    "))
  ),
  numericInput("num1", "První číslo:", value = 0),
  numericInput("num2", "Druhé číslo:", value = 0),
  actionButton("sum", "Sečíst", class = "btn-default"),
  actionButton("minus", "Odečíst", class = "btn-default"),
  textOutput("result", class = "shiny-text-output")
)

# serverová funkce
server <- function(input, output) {
  # reakce na tlačítko "Sečíst"
  observeEvent(input$sum, {
    result <- input$num1 + input$num2
    output$result <- renderText(paste("Výsledek je:", result))
  })
  # reakce na tlačítko "Odečíst"
  observeEvent(input$minus, {
    result <- input$num1 - input$num2
    output$result <- renderText(paste("Výsledek je:", result))
  })
}

# spuštění aplikace
app_instance <- shinyApp(ui, server)
port <- runApp(app_instance, port = 3838, host = "0.0.0.0")
