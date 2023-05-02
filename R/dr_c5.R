base_path <- "/workspaces/DM"
source(paste(base_path, "/R/utils.R", sep = ""))

library(C50)
library(stringr)

training_data_file <- paste(base_path, "/data/DRUG1n", sep = "")
testing_data_file <- paste(base_path, "/data/DRUG1n_test", sep = "")

testing_data <- load_data(testing_data_file)
testing_data_factor <- get_factor(testing_data)

training_data <- load_data(training_data_file)
training_data <- prepare_data(training_data)
training_data_factor <- get_factor(training_data)

model_c50 <- C5.0(training_data_factor[, -5], training_data_factor$Drug)
predikce <- predict(model_c50, testing_data_factor)
probabilities <- predict(model_c50, testing_data_factor, type = "prob")

score_table <- data.frame(
    get_score_table(predikce, testing_data),
    probabilities)
score <- get_score(score_table)

user_data_factor <- data.frame(
    Age = as.integer(25),
    Sex = "M", BP = "HIGH",
    Cholesterol = "HIGH",
    Na_to_K = 1.247,
    stringsAsFactors = TRUE
)

predikce_uzivatel <- recomend(user_data_factor, model_c50, training_data_factor)
