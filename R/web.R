source("/srv/dm/R/utils.R")
#source("/workspaces/DM/R/utils.R")

# Global export
store_user_data <- store_user_data
recomend <- recomend

library(shiny)
library(shinythemes)
library(C50)
library(CHAID)
library(stringr)

training_data_file <- "/srv/dm/data/DRUG1n"
#training_data_file <- "/workspaces/DM/data/DRUG1n"
testing_data_file <- "/srv/dm/data/DRUG1n_test"
#testing_data_file <- "/workspaces/DM/data/DRUG1n_test"
user_data_file <- "/srv/dm/data/DRUG1n_user"
#user_data_file <- "/workspaces/DM/data/DRUG1n_user"

testing_data <- load_data(testing_data_file)
testing_data_factor <- get_factor(testing_data)

training_data <- load_data(training_data_file)
training_data <- prepare_data(training_data)
training_data_factor <- get_factor(training_data)

model_chaid <- ctree(
    Drug ~ Age + Sex + BP + Cholesterol + Na_to_K,
    data = training_data_factor
)
model_c50 <- C5.0(training_data_factor[, -5], training_data_factor$Drug)

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
        background-attachment: fixed; /* přidáváme novou vlastnost */
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        color: #fff;
      }
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

  numericInput("Age", "Věk:", value = NULL, min = 1, max = 120),
  selectInput("Sex", "Pohlaví:", c("M", "F"), selected = NULL),

  selectInput("BP", "Krevní tlak:",
    c("LOW", "NORMAL", "HIGH"),
    selected = NULL
  ),

  selectInput("Cholesterol", "Cholesterol:",
    c("LOW", "NORMAL", "HIGH"),
    selected = NULL
  ),

  numericInput("Na_to_K", "Poměr Na/K:",
    value = NULL, min = 0, max = Inf, step = 0.1
  ),

  actionButton("submit", "Odeslat", class = "btn-default"),
  textOutput("result")
)

## serverová funkce
server <- function(input, output) {
    observeEvent(input$submit, {
      user_data_factor <- data.frame(
      Age = as.integer(input$Age),
      Sex = input$Sex,
      BP = input$BP,
      Cholesterol = input$Cholesterol,
      Na_to_K = as.numeric(input$Na_to_K),
      stringsAsFactors = TRUE
    )
    predikce_uzivatel_chaid <- recomend(
      user_data_factor,
      model_chaid,
      training_data_factor
    )
    predikce_uzivatel_c50 <- recomend(
      user_data_factor,
      model_c50,
      training_data_factor
    )
    result <- c("CHAID: ", predikce_uzivatel_chaid,
      " | C5.0: ", predikce_uzivatel_c50
    )
    output$result <- renderText(paste(result))
    user_data <- data.frame(
      input$Age,
      input$Sex,
      input$BP,
      input$Cholesterol,
      input$Na_to_K
    )
    store_user_data(
      user_data,
      predikce_uzivatel_c50,
      predikce_uzivatel_chaid,
      user_data_file)
  })
}

# spuštění aplikace
app_instance <- shinyApp(ui, server)
port <- runApp(app_instance, port = 3838, host = "0.0.0.0")
