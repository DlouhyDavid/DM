install.packages("shiny")
library(shiny)

# UI rozhraní
ui <- fluidPage(
  numericInput("num1", "První číslo:", value = 0),
  numericInput("num2", "Druhé číslo:", value = 0),
  actionButton("sum", "Sečíst"),
  textOutput("result")
)

# serverová funkce
server <- function(input, output) {
  # reakce na tlačítko
  observeEvent(input$sum, {
    result <- input$num1 + input$num2
    output$result <- renderText(paste("Výsledek je:", result))
  })
  
}

# spuštění aplikace
app_instance <- shinyApp(ui, server)
port <- runApp(app_instance, port = 8080)