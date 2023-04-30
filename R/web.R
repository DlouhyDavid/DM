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

      /* Nastavení pozadí s gradientem */
      body {
        background: linear-gradient(to bottom right, #fc00ff, #00dbde);
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        color: #fff; /* barva textu */
      }}
      input, button {
  background-color: #fff; /* barva pozadí inputů a tlačítek */
  color: #000; /* barva textu inputů a tlačítek */
  border: none; /* odstranění okrajů */
  padding: 8px 16px; /* vnitřní odsazení */
  border-radius: 4px; /* zakulacení rohů */
  font-size: 16px;
}

button {
  background-color: #fc00ff; /* barva pozadí tlačítka */
  color: #fff; /* barva textu tlačítka */
  transition: background-color 0.3s ease; /* animace přechodu */
  cursor: pointer; /* kurzor ruky */
}

button:hover {
  background-color: #00dbde; /* barva pozadí tlačítka při najetí myší */
}
    "))
  ),
  numericInput("num1", "První číslo:", value = 0),
  numericInput("num2", "Druhé číslo:", value = 0),
  actionButton("sum", "Sečíst", class = "btn-default"),
  actionButton("minus", "Odečíst", class = "btn-default"),
  textOutput("result"),
#
  numericInput("Age", "Věk:", value = NULL, min = 1, max = 120),
  selectInput("Sex", "Pohlaví:", c("M", "F"), selected = NULL),
  selectInput("BP", "Krevní tlak:", c("LOW", "NORMAL", "HIGH"), selected = NULL),
  selectInput("Cholesterol", "Cholesterol:", c("LOW", "NORMAL", "HIGH"), selected = NULL),
  numericInput("Na_to_K", "Poměr Na/K:", value = NULL, min = 0, max = Inf, step = 0.1),
  actionButton("submit", "Odeslat", class = "btn-default")
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
