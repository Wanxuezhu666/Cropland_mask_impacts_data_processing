

library("ggplot2")
library("glmmTMB")
library("readxl")
library(caret)
library(MuMIn)
library(plyr)


setwd('E:/01_Reseach_papers/R1_African_agriculture/Modeling/05_SPAM_RF_millet_center_year_updated')
All_data = read_excel("M03_SPAM_RF_Millet_for_modeling.xlsx", sheet = "Sheet1")


#------------Transfer to factors -----------------------------------------------
All_data$Years <- factor(All_data$Years)
All_data$Countries <- factor(All_data$Countries)

head(All_data)

#--------------Select the maize data
maize = All_data[, !names(All_data) %in% c("Maize_RYA", "Sorghum_RYA")]

#------------Seperate into different countries----------------------------------

maize_list <- list()# 

for (i in 1:46) {
  dataframe_name <- paste("country_", i, sep="")
  new_dataframe <- maize[maize$ID == i, ]
  maize_list[[dataframe_name]] <- new_dataframe
}


step_lm_result = function(i)#this function does not consider the LST-Precpitation interaction
{
  pc <- maize_list[[paste("country_", i, sep="")]]
  pc <- as.data.frame(pc)
  names(pc) <- c("Years", "ID", "Countries", "Millet_RYA", "SM1_cv", "SM1_mean", 
                 "SM2_cv", "AT_cv", "AT_mean", "AT_P95", "P_cv", 
                 "P_P95", "P_total", "ET_mean", "ET_P95", "LST_mean", "LST_P95")
  pc_f0 <- pc[complete.cases(pc), ]#pc filtering zero = pc_f0
  if (nrow(pc_f0) == 0) {
    return(NULL)
  }
  if (nrow(pc_f0) > 0) {
    rs = pc_f0[, !names(pc_f0) %in% c("Years", "Countries","Millet_RYA","ID")]
    scaled_rs <- scale(rs)
    pc_done = cbind(Maize_RYA = pc_f0$Maize_RYA,scaled_rs)
    pc_done = as.data.frame(pc_done)
    step_lm <- step(lm(Maize_RYA ~SM1_cv + SM1_mean + SM2_cv + 
                                AT_cv +AT_mean + AT_P95 + P_cv + P_total + P_P95 + 
                                ET_mean + ET_P95 + LST_mean + LST_P95, 
                              data = pc_done), direction = "both",trace = TRUE)
    step_lm_summary = summary(step_lm)
    predicted_df <- predict(step_lm, newdata = pc_done)
    R2 = step_lm_summary$r.squared
    adjust_R2 = step_lm_summary$adj.r.squared
    coefficients <- coef(step_lm_summary)[, "Estimate"]
    coefficients_df <- data.frame(coefficients)
    colnames(coefficients_df) <- c(paste("Country_", i, sep=""))
    return(list(coefficients_df = coefficients_df, R2 = R2, adjust_R2 = adjust_R2, predicted_df = predicted_df, measured = pc_done$Maize_RYA))
  }
}


num_iterations <- 46
results <- step_lm_result(num_iterations)#get the results


# ------------when considering LST-Precipitation interaction----------------------
# Using the following function to replace the step(lm()) part in the step_lm_result function.

ML_model <- glmmTMB(Maize_RYA ~ SM1_cv + SM2_cv + AT_cv + AT_mean + AT_P95 + 
                      P_P95 + ET_mean + ET_P95 + LST_mean + LST_P95 +
                      P_P95*AT_P95, data = maize_new)

