

library("ggplot2")
library("glmmTMB")
library("readxl")
library("randomForest")
library(caret)
library(MuMIn)
library(plyr)


setwd('E:/01_Reseach_papers/Co_African_agriculture/Scenario_modeling/01_MIRCA2000_RF_All_crops')
All_data = read_excel("M04_MIRCA2000_RF_All_crops_for_modeling_interaction.xlsx", sheet = "Sheet1")

# Take MFA mask as an example
 
All_data$Years <- factor(All_data$Years)
All_data$Countries <- factor(All_data$Countries)

head(All_data)

maize = All_data[, !names(All_data) %in% c("Millet_RYA", "Sorghum_RYA")]

#-----------------Divide into different countries --------------------------

maize_list <- list()

for (i in 1:46) {
  dataframe_name <- paste("country_", i, sep="")
  new_dataframe <- maize[maize$ID == i, ]
  maize_list[[dataframe_name]] <- new_dataframe
}


step_lm_result = function(i)
{
  pc <- maize_list[[paste("country_", i, sep="")]]
  pc <- as.data.frame(pc)
  names(pc) <- c("Years", "ID", "Countries", "Maize_RYA", "SM1_cv", "SM1_mean", 
                 "SM2_cv", "AT_cv", "AT_mean", "AT_P95", "P_cv", 
                 "P_P95", "P_total", "ET_mean", "ET_P95", "LST_mean", "LST_P95","P_LST")
  pc_f0 <- pc[complete.cases(pc), ]#pc filtering zero = pc_f0
  if (nrow(pc_f0) == 0) {
    return(NULL)
  }
  if (nrow(pc_f0) > 0) {
    rs = pc_f0[, !names(pc_f0) %in% c("Years", "Countries","Maize_RYA","ID")]
    scaled_rs <- scale(rs)#-------------------------------------------------------normalized remote sensing variables
    pc_done = cbind(Maize_RYA = pc_f0$Maize_RYA,scaled_rs)
    pc_done = as.data.frame(pc_done)#---------------------------------------------Data for modeling
    step_lm <- step(lm(Maize_RYA ~SM1_cv + SM1_mean + SM2_cv + 
                                AT_cv +AT_mean + AT_P95 + P_cv + P_total + P_P95 + 
                                ET_mean + ET_P95 + LST_mean + LST_P95+P_LST, 
                              data = pc_done), direction = "both",trace = TRUE)
    step_lm_summary = summary(step_lm)
    predicted_df <- predict(step_lm, newdata = pc_done)
    R2 = step_lm_summary$r.squared
    adjust_R2 = step_lm_summary$adj.r.squared
    coefficients <- coef(step_lm_summary)[, "Estimate"]
    coefficients_df <- data.frame(coefficients)
    colnames(coefficients_df) <- c(paste("Country_", i, sep=""))#-----------------Give country name
    return(list(coefficients_df = coefficients_df, R2 = R2, adjust_R2 = adjust_R2, predicted_df = predicted_df, measured = pc_done$Maize_RYA))
  }
}



R2 = numeric(length = 46)
AR2 = numeric(length = 46)
P = c()
RYA = c()
ID = c()

# here we only list 3 countries, a total of 46 countries
i = 1 
C1= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P = unname(step_lm_result(i)$predicted_df); RYA = step_lm_result(i)$measured;length_RYA = length(RYA);ID = rep(i, times = length_RYA)

i = 2
C2= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 3
C3= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)


RYA_compare <- cbind(RYA, P)
write.csv(RYA_compare,"RYA_compare_maize_INTER.csv",row.names=FALSE)


# combined data, take countries 1-8 as an example

C1_2 = merge(C1, C2, by="row.names", all=TRUE)
names(C1_2)[names(C1_2) == "Row.names"] <- "RS"
C3_4 = merge(C3, C4, by="row.names", all=TRUE)
names(C3_4)[names(C3_4) == "Row.names"] <- "RS"
C1_4 = merge(C1_2, C3_4, by="RS", all=TRUE)

C5_6 = merge(C5, C6, by="row.names", all=TRUE)
names(C5_6)[names(C5_6) == "Row.names"] <- "RS"
C7_8 = merge(C7, C8, by="row.names", all=TRUE)
names(C7_8)[names(C7_8) == "Row.names"] <- "RS"
C5_8 = merge(C5_6, C7_8, by="RS", all=TRUE)

C1_8 = merge(C1_4, C5_8, by="RS", all=TRUE)



write.csv(C_1_8,"Coefficients_RS_variables_maize.csv",row.names=FALSE)
write.csv(R2,"R2.csv",row.names=FALSE)
write.csv(AR2,"AR2.csv",row.names=FALSE)
RYA_compare <- cbind(ID, RYA, P)
write.csv(RYA_compare,"RYA_compare_maize.csv",row.names=FALSE)
