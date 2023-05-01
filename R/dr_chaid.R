source("/workspaces/DM/R/utils.R")

library(CHAID)
library(stringr)

training_data_file <- "/workspaces/DM/data/DRUG1n"
testing_data_file <- "/workspaces/DM/data/DRUG1n_test"

testing_data <- load_data(testing_data_file)
testing_data_factor <- get_factor(testing_data)

training_data <- load_data(training_data_file)
training_data <- prepare_data(training_data)
training_data_factor <- get_factor(training_data)

model_chaid <- ctree(
    Drug ~ Age + Sex + BP + Cholesterol + Na_to_K,
    data = training_data_factor
)

predikce <- predict(model_chaid, testing_data_factor)

score_table <- get_score_table(predikce, testing_data)
score <- get_score(score_table)

user_data_factor <- data.frame(
    Age = as.integer(25),
    Sex = "M", BP = "HIGH",
    Cholesterol = "HIGH",
    Na_to_K = 1.247,
    stringsAsFactors = TRUE
)

predikce_uzivatel <- recomend(
    user_data_factor,
    model_chaid,
    training_data_factor
)
