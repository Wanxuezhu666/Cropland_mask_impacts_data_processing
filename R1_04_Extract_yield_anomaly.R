
setwd("E:/01_Reseach_papers/R1_African_agriculture/Data")


library("ggplot2")
library("readxl")

mydata = read_excel("05_Millet_for_RYA_extract.xlsx", sheet = "Sheet1")

# Process each column A1 to A59
# A1 to A59 are different African countries
# For data processing, we used A1, A2, A3,... A59 to represent different countries

# Initialize result matrix
result = matrix(data = NA, nrow = 33, ncol = 60, byrow = FALSE, dimnames = NULL)
span_value = 0.55


# Process each column A1 to A59
for (i in 1:59) {
  column_name = paste0("A", i)
  # Check if the entire column is empty (all NA)
  if (all(is.na(mydata[[column_name]]))) {
    next  # Skip to the next iteration if the column is empty
  }
  # Fit the model and calculate result
  model = loess(as.formula(paste0(column_name, "~ Year")), data = mydata, degree = 1, na.translate = FALSE, span = span_value)
  result[, i] = (mydata[[column_name]] / predict(model, mydata$Year, level = 0.95)) - 1
}

# Write result to CSV
write.csv(result, "06_Millet_RYA_new.csv", row.names = FALSE)






