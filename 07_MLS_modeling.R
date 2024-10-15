

library("ggplot2")
library("glmmTMB")
library("readxl")
library("randomForest")
library(caret)
library(MuMIn)
library(plyr)


setwd('E:/01_Reseach_papers/Co_African_agriculture/Scenario_modeling/01_MIRCA2000_RF_All_crops')
All_data = read_excel("M04_MIRCA2000_RF_All_crops_for_modeling_interaction.xlsx", sheet = "Sheet1")

setwd('E:/01_Reseach_papers/Co_African_agriculture/Scenario_modeling/02_MIRCA2000_RF_IR_All_crops')
All_data = read_excel("M04_MIRCA2000_RF_IR_All_crops_for_modeling_interaction.xlsx", sheet = "Sheet1")

setwd('E:/01_Reseach_papers/Co_African_agriculture/Scenario_modeling/03_MIRCA2000_RF_maize')
All_data = read_excel("M04_MIRCA2000_RF_maize_for_modeling_interaction.xlsx", sheet = "Sheet1")

setwd('E:/01_Reseach_papers/Co_African_agriculture/Scenario_modeling/04_SPAM_RF_All_crops_center_year')
All_data = read_excel("M03_SPAM_RF_All_crops_for_modeling.xlsx", sheet = "Sheet1")

setwd('E:/01_Reseach_papers/Co_African_agriculture/Scenario_modeling/04_SPAM_RF_All_crops_center_year')
All_data = read_excel("M04_SPAM_RF_All_crops_for_modeling_interactions.xlsx", sheet = "Sheet1")

setwd('E:/01_Reseach_papers/Co_African_agriculture/Scenario_modeling/05_SPAM_RF_maize_center_year')
All_data = read_excel("M03_SPAM_RF_Maize_for_modeling.xlsx", sheet = "Sheet1")

#------------将列转化为因子---------------
All_data$Years <- factor(All_data$Years)
All_data$Countries <- factor(All_data$Countries)

head(All_data)

#只保留玉米的数据
maize = All_data[, !names(All_data) %in% c("Millet_RYA", "Sorghum_RYA")]

#-----------------拆分为不同的国家数据

maize_list <- list()# 创建一个空列表，用于存储生成的数据框

# 循环创建数据框
for (i in 1:46) {
  dataframe_name <- paste("country_", i, sep="")# 生成数据框名称
  new_dataframe <- maize[maize$ID == i, ]# 使用逻辑向量过滤数据框
  maize_list[[dataframe_name]] <- new_dataframe# 将新数据框添加到列表中
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
    scaled_rs <- scale(rs)#-------------------------------------------------------归一化遥感变量
    pc_done = cbind(Maize_RYA = pc_f0$Maize_RYA,scaled_rs)#-----------------------将归一化后的rs变量和RYA数据合并
    pc_done = as.data.frame(pc_done)#---------------------------------------------准备好的用于建模的数据
    step_lm <- step(lm(Maize_RYA ~SM1_cv + SM1_mean + SM2_cv + 
                                AT_cv +AT_mean + AT_P95 + P_cv + P_total + P_P95 + 
                                ET_mean + ET_P95 + LST_mean + LST_P95+P_LST, 
                              data = pc_done), direction = "both",trace = TRUE)#--建立多元线性回归模型
    step_lm_summary = summary(step_lm)
    predicted_df <- predict(step_lm, newdata = pc_done)
    R2 = step_lm_summary$r.squared
    adjust_R2 = step_lm_summary$adj.r.squared
    coefficients <- coef(step_lm_summary)[, "Estimate"]#------------------ 输出每个参数的系数
    coefficients_df <- data.frame(coefficients)
    colnames(coefficients_df) <- c(paste("Country_", i, sep=""))#-----------------重命名为国家编号
    return(list(coefficients_df = coefficients_df, R2 = R2, adjust_R2 = adjust_R2, predicted_df = predicted_df, measured = pc_done$Maize_RYA))
  }
}




#for (i in 1:51) {assign(paste("C", i, sep=""), step_lm_result(i))} #-----循环调用函数，生成相应的结果，并将结果存储在以相应数字结尾的变量中
R2 = numeric(length = 46)
AR2 = numeric(length = 46)
P = c()
RYA = c()
ID = c()

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

i = 4
C4= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 5
C5= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2;
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 6
C6= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 7
C7= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 8
C8= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
#length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 9
C9= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 10
C10= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 11
C11= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
#length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 12
C12= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2;
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 13
C13= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
#length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)


i = 14
C14= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2;
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 15
C15= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 16
C16= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 17
C17= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 18
C18= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 19
C19= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 20
C20= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 21
C21= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 22
C22= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 23
C23= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 24
C24= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 25
C25= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2;
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 26
C26= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2;
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 27
C27= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 28
C28= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2;
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 29
C29= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2;
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 30
C30= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 31
C31= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2;
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 32
C32= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2;
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 33
C33= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 34
C34= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 35
C35= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 36
C36= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 37
C37= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 38
C38= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 39
C39= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 40
C40= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 41
C41= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 42
C42= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
#length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 43
C43= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 44
C44= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
#length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 45
C45= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)

i = 46
C46= step_lm_result(i)$coefficients_df; R2[i] = step_lm_result(i)$R2; AR2[i] = step_lm_result(i)$adjust_R2; 
P_new = unname(step_lm_result(i)$predicted_df);P=c(P,P_new); RYA_new = step_lm_result(i)$measured; RYA = c(RYA,RYA_new)
length_RYA = length(RYA_new);ID_new = rep(i, times = length_RYA); ID = c(ID,ID_new)



RYA_compare <- cbind(RYA, P)
write.csv(RYA_compare,"RYA_compare_maize_INTER.csv",row.names=FALSE)









C1 = C2
C12 = C11
C13 = C14
C23 = C22
C28 = C27



C8 = C7
C11 = C10
C13 = C12
#C31 = C30
C42 = C41
C44 = C43


# 将它们按照行名合并，并将缺失值填充为0
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
##########################################################


C9_10 = merge(C9, C10, by="row.names", all=TRUE)
names(C9_10)[names(C9_10) == "Row.names"] <- "RS"
C11_12 = merge(C11, C12, by="row.names", all=TRUE)
names(C11_12)[names(C11_12) == "Row.names"] <- "RS"
C9_12 = merge(C9_10, C11_12, by="RS", all=TRUE)


C13_14 = merge(C13, C14, by="row.names", all=TRUE)
names(C13_14)[names(C13_14) == "Row.names"] <- "RS"
C15_16 = merge(C15, C16, by="row.names", all=TRUE)
names(C15_16)[names(C15_16) == "Row.names"] <- "RS"
C13_16 = merge(C13_14, C15_16, by="RS", all=TRUE)

C9_16 = merge(C9_12, C13_16, by="RS", all=TRUE)
C1_16 = merge(C1_8, C9_16, by="RS", all=TRUE)
#############################################################

C17_18 = merge(C17, C18, by="row.names", all=TRUE)
names(C17_18)[names(C17_18) == "Row.names"] <- "RS"
C19_20 = merge(C19, C20, by="row.names", all=TRUE)
names(C19_20)[names(C19_20) == "Row.names"] <- "RS"
C17_20 = merge(C17_18, C19_20, by="RS", all=TRUE)


C21_22 = merge(C21, C22, by="row.names", all=TRUE)
names(C21_22)[names(C21_22) == "Row.names"] <- "RS"
C23_24 = merge(C23, C24, by="row.names", all=TRUE)
names(C23_24)[names(C23_24) == "Row.names"] <- "RS"
C21_24 = merge(C21_22, C23_24, by="RS", all=TRUE)

C17_24 = merge(C17_20, C21_24, by="RS", all=TRUE)

#############################################################

C25_26 = merge(C25, C26, by="row.names", all=TRUE)
names(C25_26)[names(C25_26) == "Row.names"] <- "RS"
C27_28 = merge(C27, C28, by="row.names", all=TRUE)
names(C27_28)[names(C27_28) == "Row.names"] <- "RS"
C25_28 = merge(C25_26, C27_28, by="RS", all=TRUE)

C29_30 = merge(C29, C30, by="row.names", all=TRUE)
names(C29_30)[names(C29_30) == "Row.names"] <- "RS"
C31_32 = merge(C31, C32, by="row.names", all=TRUE)
names(C31_32)[names(C31_32) == "Row.names"] <- "RS"
C29_32 = merge(C29_30, C31_32, by="RS", all=TRUE)

C25_32 = merge(C25_28, C29_32, by="RS", all=TRUE)
C17_32 = merge(C17_24, C25_32, by="RS", all=TRUE)

C1_32 = merge(C1_16, C17_32, by="RS", all=TRUE)#-----------------------------------

##############################################################

C33_34 = merge(C33, C34, by="row.names", all=TRUE)
names(C33_34)[names(C33_34) == "Row.names"] <- "RS"
C35_36 = merge(C35, C36, by="row.names", all=TRUE)
names(C35_36)[names(C35_36) == "Row.names"] <- "RS"
C33_36 = merge(C33_34, C35_36, by="RS", all=TRUE)

C1_36 = merge(C1_32, C33_36, by="RS", all=TRUE)#

C37_38 = merge(C37, C38, by="row.names", all=TRUE)
names(C37_38)[names(C37_38) == "Row.names"] <- "RS"
C39_40 = merge(C39, C40, by="row.names", all=TRUE)
names(C39_40)[names(C39_40) == "Row.names"] <- "RS"
C37_40 = merge(C37_38, C39_40, by="RS", all=TRUE)

C1_40 = merge(C1_36, C37_40, by="RS", all=TRUE)#

############################################################

C41_42 = merge(C41, C42, by="row.names", all=TRUE)
names(C41_42)[names(C41_42) == "Row.names"] <- "RS"
C43_44 = merge(C43, C44, by="row.names", all=TRUE)
names(C43_44)[names(C43_44) == "Row.names"] <- "RS"
C41_44 = merge(C41_42, C43_44, by="RS", all=TRUE)


C45_46 = merge(C45, C46, by="row.names", all=TRUE)
names(C45_46)[names(C45_46) == "Row.names"] <- "RS"


C41_46 = merge(C41_44, C45_46, by="RS", all=TRUE)#

C_all = merge(C1_40, C41_46, by="RS", all=TRUE)#

C_all <- subset(C_all, select = -c(Country_7.y,Country_12.y,Country_30.y,Country_41.y,Country_43.y))


names(C_all)[names(C_all) == "Country_7.x"] <- "Country_7"
names(C_all)[names(C_all) == "Country_12.x"] <- "Country_12"
names(C_all)[names(C_all) == "Country_30.x"] <- "Country_30"
names(C_all)[names(C_all) == "Country_41.x"] <- "Country_41"
names(C_all)[names(C_all) == "Country_43.x"] <- "Country_43"



#Algeria_data <- as.matrix(Algeria_data)


write.csv(C_all,"Coefficients_RS_variables_maize.csv",row.names=FALSE)

write.csv(R2,"R2.csv",row.names=FALSE)

write.csv(AR2,"AR2.csv",row.names=FALSE)

RYA_compare <- cbind(ID, RYA, P)
write.csv(RYA_compare,"RYA_compare_maize.csv",row.names=FALSE)


P1_2 = merge(P1, P2, by="row.names", all=TRUE)

names(P1_2)[names(P1_2) == "Row.names"] <- "Year"
names(P1_2)[names(P1_2) == "Country_7.x"] <- "Country_7"











pc = maize_list["country_2"]#查看一下数据, pc = processing country
pc <- as.data.frame(pc)
names(pc) <- c("Years", "ID", "Countries", "Maize_RYA", "SM1_cv", "SM1_mean", 
                         "SM1_P95", "SM2_cv", "AT_cv", "AT_mean", "AT_P95", "P_cv", 
                         "P_P95", "P_total", "ET_mean", "ET_P95", "LST_mean", "LST_P95")

#剔除空值
pc_f0 <- pc[complete.cases(pc), ]#pc filtering zero = pc_f0
head(pc_f0)

#提取出遥感变量，归一化处理
rs = pc_f0[, !names(pc_f0) %in% c("Years", "Countries","Maize_RYA","ID")]
scaled_rs <- scale(rs)

#将归一化后的rs变量和RYA数据合并
pc_done = cbind(Maize_RYA = pc_f0$Maize_RYA,scaled_rs)
pc_done = as.data.frame(pc_done)
pc_done#-------------------------准备好的用于建模的数据


#建立多元线性回归模型
step_lm_maize <- step(lm(Maize_RYA ~SM1_cv + SM1_mean + SM1_P95 + SM2_cv + AT_cv + 
                                    AT_mean + AT_P95 + P_cv + P_total + P_P95 + 
                                    ET_mean + ET_P95 + LST_mean + LST_P95, 
                        data = pc_done), direction = "both", trace = TRUE)
step_lm_maize_summary = summary(step_lm_maize)
R2 = step_lm_maize_summary$r.squared
adjust_R2 = step_lm_maize_summary$adj.r.squared

R2
adjust_R2

# 输出每个参数的系数
coefficients_2 <- coef(step_lm_maize_summary)[, "Estimate"]
coefficients_df_2 <- data.frame(coefficients_2)
colnames(coefficients_df_2) <- c("Country_2")#重命名为国家编号


coefficients_df_1
coefficients_df_2

# 将它们按照行名合并，并将缺失值填充为0
merged_df <- merge(coefficients_df_1, coefficients_df_2, by="row.names", all=TRUE)
#merged_df[is.na(merged_df)] <- 0

# 查看合并后的数据框
print(merged_df)




variables <- names(coef(step_lm_maize))


# 创建一个包含所有自变量的系数向量，初始值为0
coefficients <- rep(0, length(variables))




























ML_model <- glmmTMB(Maize_RYA ~ SM1_cv + SM2_cv + AT_cv + AT_mean + AT_P95 + 
                      P_P95 + ET_mean + ET_P95 + LST_mean + LST_P95 +
                      P_P95*AT_P95, 
                    data = maize_new)

summary(ML_model)

# 计算调整R²
adjusted_r_squared <- r.squaredGLMM(ML_model)
adjusted_r_squared



pre2 <- predict(ML_model, newdata = maize_new)



# 拟合线性模型
lm_model <- lm(maize_new$Maize_RYA ~ pre2, data = maize_new)

# 提取R²值
r_squared <- summary(lm_model)$r.squared


r_squared













#只保留玉米的数据
maize = A2[, !names(A2) %in% c("Millet_RYA", "Sorghum_RYA","Years")]

#提取出遥感变量，归一化处理
rs = A2[, !names(A2) %in% c("Millet_RYA", "Sorghum_RYA","Years","Maize_RYA")]
scaled_rs <- scale(rs)

#将归一化后的rs变量和RYA数据合并
maize_new = cbind(Maize_RYA = maize$Maize_RYA,scaled_rs)

##删除包含有空值的行
maize_new <- maize_new[complete.cases(maize_new), ]
maize_new <- as.data.frame(maize_new)


#建立多元线性回归模型
M1_maize_RYA <- step(lm(Maize_RYA ~SM1_cv + SM1_mean + SM1_P95 + SM2_cv + AT_cv + 
                                   AT_mean + AT_P95 + P_cv + P_total + P_P95 + 
                                   ET_mean + ET_P95 + LST_mean + LST_P95, 
                    data = maize_new), direction = "both", trace = TRUE)
summary(M1_maize_RYA)



ML_model <- glmmTMB(Maize_RYA ~ SM1_cv + SM2_cv + AT_cv + AT_mean + AT_P95 + 
                                P_P95 + ET_mean + ET_P95 + LST_mean + LST_P95 +
                                P_P95*AT_P95, 
                    data = maize_new)

summary(ML_model)

# 计算调整R²
adjusted_r_squared <- r.squaredGLMM(ML_model)
adjusted_r_squared



pre2 <- predict(ML_model, newdata = maize_new)



# 拟合线性模型
lm_model <- lm(maize_new$Maize_RYA ~ pre2, data = maize_new)

# 提取R²值
r_squared <- summary(lm_model)$r.squared


r_squared










mydata <- read.table("try.csv", header=TRUE, sep=",", quote="", fill=TRUE, na.strings="")

mydata$Maize_RYA

maize = mydata[, !names(mydata) %in% c("Millet_RYA", "Sorghum_RYA")]#选择玉米数据处理
head(mydata)
head(maize)

# 对数据框中的所有数据保留5位小数
df <- round(df, 5)



#删除包含有空值的行
maize <- maize[complete.cases(maize), ]
rs_variables = maize[, !names(maize) %in% c("order", "years","countries","ZHU_ID","Yang_ID","Maize_RYA")]#选择玉米数据处理
head(rs_variables)
#数据归一化处理
rs_variables <- apply(rs_variables, 2, function(x) (x - min(x)) / (max(x) - min(x)))

maize_new <- cbind(Maize_RYA = maize$Maize_RYA,rs_variables) 
head(maize_new)
#M1_maize_AYA <- step(lm(AYA ~AT14+AT20+ATmin+GT8+GT20+GTmean+GTmax+GTmin+S5T8+S5T14+S5T20+S5Tmean+S10T8+S10T14+S15T14+S15T20+S20T14+S20T20+SH+EP+Rain, data = maize),direction = "both", trace = TRUE)
#summary(M1_maize_AYA)
#pre1 <- predict(M1_maize_AYA, newdata = maize)
#plot1 = plot_scatter_ggplot(maize$AYA,pre1,title = "M1: Climate (C)",x_label = "Measured AYA",y_label = "Estimated AYA")
#plot1
maize_new <- as.data.frame(maize_new)

M1_maize_RYA <- step(lm(Maize_RYA ~SM1_cv+SM1_mean+SM1_P95+SM2_cv+SM2_mean+SM2_P95+
                                   ST1_cv+ST1_mean+ST1_P95+ST2_cv+ST2_mean+ST2_P95+
                                   AT_cv+AT_mean+AT_P95+P_cv+P_mean+P_P95+P_total+
                                   ET_mean+ET_P95+ET_Q3+LST_mean+LST_P95+LST_Q3, data = maize_new), direction = "both", trace = TRUE)
summary(M1_maize_RYA)


pre1 <- predict(M1_maize_RYA, newdata = maize_new)
plot1 = plot(maize_new$Maize_RYA,pre1,x_label = "Measured RYA",y_label = "Estimated RYA")

predictions = data.frame(maize_RYA = maize_new$Maize_RYA, Pre1 = pre1)
write.csv(predictions, file = "maize_RYA_prediction.csv", row.names = FALSE)








A1_data <- mydata[,c("Year","A1")]

#Algeria_data <- as.matrix(Algeria_data)


write.csv(result,"06_Sorghum_RYA.csv",row.names=FALSE)




