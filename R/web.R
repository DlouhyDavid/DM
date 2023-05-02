library(shiny)
library(shinythemes)
library(C50)
library(CHAID)
library(stringr)
library(ggplot2)

base_path <- "/workspaces/DM"

source(paste(base_path, "/R/utils.R", sep = ""))

# Global export
store_user_data <- store_user_data
recomend <- recomend
load_user_data <- load_user_data

training_data_file <- paste(base_path, "/data/DRUG1n", sep = "")
testing_data_file <- paste(base_path, "/data/DRUG1n_test", sep = "")
user_data_file <- paste(base_path, "/data/DRUG1n_user", sep = "")
image_rec <- paste(base_path, "/data/modal_rec.jpg", sep = "")

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
  fluidRow(
  column(width = 6, 
         actionButton("submit", "Odeslat", class = "btn-default")
  ),
  column(width = 6,
         actionButton("show_plot", "Zobrazit grafy", class = "btn-default")
  )
)
)

## serverová funkce
server <- function(input, output) {
  output$image <- renderImage({
            list(src = image_rec,
                 alt = "Doporučení",
                 width = "100%",
                 height = "auto"
            )
        }, deleteFile = FALSE)
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

    result_chaid <- paste("CHAID: ", predikce_uzivatel_chaid
    )

    result_c50 <- paste("C5.0: ", predikce_uzivatel_c50
    )
  
  showModal(modalDialog(
      tags$h3("DOPORUČENÝ LÉK:",
        style = "text-align:center; font-weight:bold; color:#082948;"
      ),
      br(),
      tags$p(result_chaid, style = "text-align:center; color:#082948;"),
      tags$p(result_c50, style = "text-align:center; color:#082948;"),
      br(),
      imageOutput('image'),
      easyClose = TRUE,
      footer = NULL
    ))

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
      user_data_file
    )
  })
  # funkce pro zobrazení modálního okna s grafem po kliknutí na tlačítko
  observeEvent(input$show_plot, {
    loaded_user_data <- load_user_data(user_data_file)
    # kód pro výpočet dat pro graf
    output$graf_chaid <- renderPlot({
      # výpočet četností
      freq_table <- table(loaded_user_data$RecomendCHAID)
      #freq_table <- table(loaded_user_data$RecomendC50)
      #freq_table <- table(loaded_user_data$Time)
      # vytvoření sloupcového grafu
      barplot(freq_table, main = "Doporučení dle CHAID", xlab = "Lék", ylab = "Počet")
    })
    output$graf_c50 <- renderPlot({
      freq_table <- table(loaded_user_data$RecomendC50)
      barplot(freq_table, main = "Doporučení dle C5.0", xlab = "Lék", ylab = "Počet")
    })
output$graf_time <- renderPlot({
  # Převod časových údajů na formát s datumem a časem
  loaded_user_data$DateTime <- as.POSIXct(loaded_user_data$Time, format = "%Y-%m-%d %H:%M:%S")

  # Vytvoření data frame s jednotkovými hodnotami v počtu vkládání dat a jejich časovými údaji
  df <- data.frame(DateTime = loaded_user_data$DateTime, Četnost = rep(1, length(loaded_user_data$DateTime)))
  df <- aggregate(df$Četnost, by = list(DateTime = df$DateTime), FUN = sum)

  # Vykreslení histogramu časové řady
  ggplot(df, aes(x = DateTime)) +
    geom_histogram(fill = "purple", color = "white", binwidth = 3600, aes(y = after_stat(count))) +
    labs(x = "Datum a čas", y = "Počet vkládání dat", title = "Četnost vkládání dat") +
    scale_x_datetime(date_labels = "%Y-%m-%d %H:%M:%S") + 
    theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5, color = "black"))
})
    showModal(modalDialog(
      plotOutput("graf_time"),
      plotOutput("graf_chaid"),
      plotOutput("graf_c50"),
      easyClose = TRUE,
      footer = NULL,
    ))
  })
}

# spuštění aplikace
app_instance <- shinyApp(ui, server)
port <- runApp(app_instance, port = 3838, host = "0.0.0.0")
