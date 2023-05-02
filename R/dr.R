# import modulů
base_path <- "/workspaces/DM"
source(paste(base_path, "/R/utils.R", sep = ""))

# import knihoven
library(C50)
library(CHAID)
library(stringr)
library(ggplot2)

# Definice cest
training_data_file <- paste(base_path, "/data/DRUG1n", sep = "")
testing_data_file <- paste(base_path, "/data/DRUG1n_test", sep = "")

# Načtení testovacích dat
testing_data <- load_data(testing_data_file)
# Tabulka šmírovačka
View(testing_data)
# Převedení na faktory
testing_data_factor <- get_factor(testing_data)

# Načtení trénovacích dat
training_data <- load_data(training_data_file)
# Seřazení dat podle sloupce "Drug" podle abecedy
training_data_sorted <- training_data[order(factor(training_data$Drug, levels = rev(unique(training_data$Drug)))),]
# Vykreslení sloupcového grafu
drug_counts <- rev(table(training_data_sorted$Drug))
barplot(drug_counts, main="Četnost hodnot ve sloupci Drug", xlab="Hodnota", ylab="Počet", horiz=TRUE)
# Vykreslení bodového grafu s barevnými body
colors <- c("purple", "red", "#0000ff", "#00ff08", "#9d9d07")[as.numeric(factor(training_data_sorted$Drug))]
plot(training_data_sorted$Na, training_data_sorted$K, col = colors, main = "Graf s barevnými body podle hodnot v t_data$Drug", xlab = "Hodnota Na", ylab = "Hodnota K", pch=19)
# Příprava sloupce Na_to_K
training_data <- prepare_data(training_data)
# Převedení na faktory
training_data_factor <- get_factor(training_data)

#Histogram Na_to_K
hist_Na_to_K <- ggplot(training_data, aes(x = Na_to_K, fill = Drug)) +
  geom_histogram(bins = 30, position = "stack") +
  xlab("Na_to_K") + ylab("Počet") +
  ggtitle("Histogram Na_to_K s ohledem na hodnoty z Drug") +
  scale_fill_discrete(name = "Drug")
show(hist_Na_to_K)

# Připrava modelu C5.0
model_c50 <- C5.0(training_data_factor[, -5], training_data_factor$Drug)
predikce_c50 <- predict(model_c50, testing_data_factor)
probabilities_c50 <- predict(model_c50, testing_data_factor, type = "prob")
score_table_c50 <- data.frame(
    get_score_table(predikce_c50, testing_data),
    probabilities_c50)
score_c50 <- get_score(score_table_c50)
cat("Počet špatných predikcí C5.0: ", score_c50, "\n")
View(score_table_c50)
plot(model_c50)
# Příprava modelu CHAID
model_chaid <- ctree(
    Drug ~ Age + Sex + BP + Cholesterol + Na_to_K,
    data = training_data_factor
)
predikce_chaid <- predict(model_chaid, testing_data_factor)
probabilities_chaid <- predict(model_chaid, testing_data_factor, type = "prob")
score_table_chaid <- data.frame(
    get_score_table(predikce_chaid, testing_data),
    probabilities_chaid)
score_chaid <- get_score(score_table_chaid)
cat("Počet špatných predikcí CHAID: ", score_chaid, "\n")
View(score_table_chaid)
plot(model_chaid)


# Doporučení uživateli
user_data_factor <- data.frame(
    Age = as.integer(25),
    Sex = "M", BP = "HIGH",
    Cholesterol = "HIGH",
    Na_to_K = 1.247,
    stringsAsFactors = TRUE
)
predikce_uzivatel_c50 <- recomend(user_data_factor, model_c50, training_data_factor)
View(predikce_uzivatel)
predikce_uzivatel_chaid <- recomend(user_data_factor, model_chaid, training_data_factor)
View(data.frame(predikce_uzivatel_c50, predikce_uzivatel_chaid))