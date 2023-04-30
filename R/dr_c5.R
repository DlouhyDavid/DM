#install.packages("C50")
library(C50)
library(stringr)

test_data <- read.csv("/workspaces/DM/data/DRUG1n_test")
test_data_factor <- data.frame(unclass(test_data), stringsAsFactors = TRUE) # Převední na factor
test_data_factor$Sex <- as.factor(test_data_factor$Sex)
test_data_factor$BP <- as.factor(test_data_factor$BP)
test_data_factor$Cholesterol <- as.factor(test_data_factor$Cholesterol)

t_data <- read.csv("/workspaces/DM/data/DRUG1n")
t_data$Na_to_K <- t_data$Na / t_data$K
t_data$Na <- NULL
t_data$K <- NULL

t_data_factor <- data.frame(unclass(t_data), stringsAsFactors = TRUE) # Převední na factor
t_data_factor$Sex <- as.factor(t_data_factor$Sex)
t_data_factor$BP <- as.factor(t_data_factor$BP)
t_data_factor$Cholesterol <- as.factor(t_data_factor$Cholesterol)

model_c50 <- C5.0(t_data_factor[, -5], t_data_factor$Drug)
predikce <- predict(model_c50, test_data_factor)

x1 <- as.character(predikce)
x2 <- test_data$Drug
x3 <- str_detect(x1, x2, negate = TRUE)
x <- data.frame(x1,x2, x3)
pocet_rozdilu <- sum(x3)
#
View(x)

# Od uživatele
new_data_factor <- data.frame(Age = as.integer(25), Sex = "M", BP = "HIGH", Cholesterol = "HIGH", Na_to_K = 1.247, stringsAsFactors = TRUE)
new_data_factor$Sex <- as.factor(new_data_factor$Sex)
new_data_factor$BP <- as.factor(new_data_factor$BP)
new_data_factor$Cholesterol <- as.factor(new_data_factor$Cholesterol)
new_data_factor$Sex <- factor(new_data_factor$Sex, levels=levels(t_data_factor$Sex))
new_data_factor$BP <- factor(new_data_factor$BP, levels=levels(t_data_factor$BP))
new_data_factor$Cholesterol <- factor(new_data_factor$Cholesterol, levels=levels(t_data_factor$Cholesterol))

predikce_uzivatel <- as.character(predict(model_c50, newdata = new_data_factor))

View(predikce_uzivatel)
View(t_data_factor)