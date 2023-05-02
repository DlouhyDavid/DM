library(stringr)

# Načte data
load_data <- function(file_path) {
  data <- read.csv(file_path)
  return(data)
}

# Převede data na faktory
get_factor <- function(data) {
    data_factor <- data.frame(unclass(data), stringsAsFactors = TRUE)
    data_factor$Sex <- as.factor(data_factor$Sex)
    data_factor$BP <- as.factor(data_factor$BP)
    data_factor$Cholesterol <- as.factor(data_factor$Cholesterol)
    return(data_factor)
}

# Připraví data
prepare_data <- function(data) {
    data$Na_to_K <- data$Na / data$K
    data$Na <- NULL
    data$K <- NULL
    return(data)
}

# Připraví tabluku pro výpočet skóré
get_score_table <- function(predikce, data) {
    x1 <- as.character(predikce)
    x2 <- data$Drug
    x3 <- str_detect(x1, x2, negate = TRUE)
    return(data.frame(x1,x2, x3))
}

# Vrátí skóré
get_score <- function(score_table) {
    return(sum(score_table$x3))
}

# Doporučení léčby
recomend <- function(user_data, model, training_data_factor) {
    user_data$Sex <- as.factor(user_data$Sex)
    user_data$BP <- as.factor(user_data$BP)
    user_data$Cholesterol <- as.factor(user_data$Cholesterol)
    user_data$Sex <- factor(
        user_data$Sex,
        levels = levels(training_data_factor$Sex)
    )
    user_data$BP <- factor(
        user_data$BP,
        levels = levels(training_data_factor$BP)
    )
    user_data$Cholesterol <- factor(
        user_data$Cholesterol,
        levels = levels(training_data_factor$Cholesterol)
    )
    return(as.character(predict(model, newdata = user_data)))
}

# Uloží data od uživatele včetně odpovědi
store_user_data <- function(user_data, recomend_c50, recomend_chaid, path) {
    write.table(
        cbind(user_data, recomend_c50, recomend_chaid),
        file = path,
        sep = ";",
        row.names = FALSE, col.names = FALSE,
        append = TRUE
    )
}
