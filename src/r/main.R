# Run from the repository root. Docker already uses /app as its working directory.
features <- c("Pclass", "Sex", "Age", "SibSp", "Parch", "Fare")
for (name in c("train.csv", "test.csv")) {
  if (!file.exists(file.path("src", "data", name))) {
    stop(paste("Download", name, "from Kaggle into src/data."))
  }
}
train <- read.csv("src/data/train.csv", stringsAsFactors = FALSE)
test <- read.csv("src/data/test.csv", stringsAsFactors = FALSE)
cat("Training rows:", nrow(train), "Test rows:", nrow(test), "\n")
cat("\nMissing values in selected training columns:\n")
print(colSums(is.na(train[features])))
cat("\nSurvival rate by sex:\n")
print(aggregate(Survived ~ Sex, train, mean))
cat("\nSurvival rate by passenger class:\n")
print(aggregate(Survived ~ Pclass, train, mean))
cat("\nKeep Pclass, Sex, Age, SibSp, Parch, Fare.\n")
cat("Encode male=0, female=1; fill missing predictors with training medians.\n")
train$Sex <- ifelse(train$Sex == "female", 1, 0)
test$Sex <- ifelse(test$Sex == "female", 1, 0)

# Apply replacement values learned from the fitting rows only.
fill_missing <- function(data, medians) {
  for (column in features) {
    data[[column]][is.na(data[[column]])] <- medians[[column]]
  }
  return(data)
}

# Sample 80% of each outcome group for a reproducible, stratified split.
set.seed(42)
index <- unlist(lapply(split(seq_len(nrow(train)), train$Survived), function(rows) {
  sample(rows, floor(0.8 * length(rows)))
}))
fit_data <- train[index, ]
valid_data <- train[-index, ]
medians <- sapply(fit_data[features], median, na.rm = TRUE)
fit_data <- fill_missing(fit_data, medians)
valid_data <- fill_missing(valid_data, medians)
formula <- Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare
model <- glm(formula, data = fit_data, family = binomial())
fit_predictions <- as.integer(predict(model, fit_data, type = "response") >= 0.5)
valid_predictions <- as.integer(predict(model, valid_data, type = "response") >= 0.5)
cat("\nSplit:", nrow(fit_data), "training rows,", nrow(valid_data), "validation rows.\n")
cat(sprintf("Training-split accuracy: %.4f\n", mean(fit_predictions == fit_data$Survived)))
cat(sprintf("Held-out validation accuracy: %.4f\n", mean(valid_predictions == valid_data$Survived)))

# Refit on all labeled rows, then predict the separate Kaggle test data.
cat("\nRefit logistic regression on all labeled rows.\n")
medians <- sapply(train[features], median, na.rm = TRUE)
train <- fill_missing(train, medians)
test <- fill_missing(test, medians)
final_model <- glm(formula, data = train, family = binomial())
train_predictions <- as.integer(predict(final_model, train, type = "response") >= 0.5)
cat(sprintf("Full training accuracy: %.4f\n", mean(train_predictions == train$Survived)))
result <- data.frame(
  PassengerId = test$PassengerId,
  Survived = as.integer(predict(final_model, test, type = "response") >= 0.5)
)
dir.create("outputs", showWarnings = FALSE)
write.csv(result, "outputs/r_predictions.csv", row.names = FALSE)
cat("\nFirst five test predictions:\n")
print(head(result, 5))
cat("Saved", nrow(result), "predictions to outputs/r_predictions.csv\n")
cat("Test accuracy: unavailable because Kaggle test.csv has no Survived labels.\n")
cat("Validation accuracy above is NOT the Kaggle test accuracy.\n")
cat("Upload the prediction CSV to Kaggle for a hidden-label competition score.\n")
