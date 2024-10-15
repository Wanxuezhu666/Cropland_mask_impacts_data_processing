"""
We conducted Random forest feature importance quantification
Take the GLC rainfed annual mask & maize as an example

Upated: 2024-Sep-12
By: Wanxue Zhu

"""

import numpy as np
import xlwt
import matplotlib.pyplot as plt
import xlrd
import math
import pandas as pd
import os
from sklearn.model_selection import train_test_split



os.chdir(r"E:\01_Reseach_papers\R1_African_agriculture\Data\Figure_RS_relative_contri") 

#1.1 Read data

data = pd.read_excel("Input_01_GLC_RF_yearly.xlsx", sheet_name = "Sheet1")


data = data.drop(columns=['Sorghum_RYA','Millet_RYA'], axis = 1)
country_list = data['Countries'].iloc[:46]

#1.2 Divide the data by different countries using the numbers in the ID column for segmentation
countries = {}

for i in range(47):
    country_name = 'Country_{}'.format(i)
    countries[country_name] = data[data['ID'] == i].reset_index(drop=True)

#1.3 Perform Recursive Feature Selection using Random Forest on the data for each 
#    country to calculate the relative importance values

from sklearn.datasets import make_regression
from sklearn.ensemble import RandomForestRegressor
from sklearn.feature_selection import RFE

def RF_importance(X, y, random_state=None):
    model = RandomForestRegressor(n_estimators=100, random_state=random_state)
    model.fit(X, y)
    feature_importance = model.feature_importances_
    total_importance = sum(feature_importance)
    relative_importance = (feature_importance / total_importance) * 100
    return feature_importance

importance_result = np.zeros((13, 46))  # 51 countries，25 columns

def RF_importance_each_country(random_state=None):
    for i in range(46):
        country_data = countries[f'Country_{i+1}']
        country_data_clean = country_data.dropna()
        if country_data_clean.empty:
            print(f"Country {i+1} has no data. Skipping...")
            continue
        y = country_data_clean['Maize_RYA']
        X = country_data_clean.drop(columns=['Years','ID','Countries','Maize_RYA'], axis=1)
        importance_result[:, i] = RF_importance(X, y, random_state=random_state)
        print(i)
    return 100*importance_result



#1.4 Save data
output = RF_importance_each_country(random_state=42)# 
column_name = ['SM1_cv','SM1_mean','SM2_cv',
               'AT_cv','AT_mean','AT_P95','P_cv','P_P95','P_total',
               'ET_mean','ET_P95','LST_mean','LST_P95']

output = pd.DataFrame(data=output.T,columns=column_name)

final_output = pd.concat([country_list, output], axis=1)
final_output.to_excel("Result_03_GLC_yearly_RF_RYA_maize.xlsx")



#---------------RF regression modeling ----------------------------------------

def RF_R2_each_country(random_state=None):
    R2_result = []
    y_actual_all = []
    y_predicted_all = []
    for i in range(46):
        country_data = countries[f'Country_{i+1}']
        country_data_clean = country_data.dropna()
        if country_data_clean.empty:
            print(f"Country {i+1} has no data. Skipping...")
            R2_result.append(0)
            continue
        y = country_data_clean['Maize_RYA']
        X = country_data_clean.drop(columns=['Years', 'ID', 'Countries', 'Maize_RYA'], axis=1)
        model = RandomForestRegressor(n_estimators=100, random_state=random_state)
        model.fit(X, y)
        y_pred = model.predict(X)
        y_actual_all.append(y.values)  # 保存实际值
        y_predicted_all.append(y_pred)  # 保存预测值
        r2 = r2_score(y, y_pred)
        R2_result.append(r2)
        print(i)
    return R2_result, y_actual_all, y_predicted_all


R2, y_actual, y_predicted = RF_R2_each_country(random_state=42)

R2 = pd.DataFrame({'R2_values': R2})
R2_output = pd.concat([country_list, R2], axis=1)

RFE_results = pd.merge(R2_output,final_output, on='Countries', how='outer')

RFE_results.to_excel("Result_02_GLC_yearly_RF_RFE_R2_maize.xlsx") # take G1RA mask as an example, maize data

skip_indices = [4,6,11,21,22,24,25,33,35,36,37,39,42,43,46]
y_actual_df = pd.DataFrame(y_actual).T
y_actual_df.columns = [f'Country_{i+1}' for i in range(46) if i+1 not in skip_indices]

for i in skip_indices:
    column_name = f'Country_{i}'
    y_actual_df.insert(loc=i-1, column=column_name, value=None)


y_predicted_df = pd.DataFrame(y_predicted).T
y_predicted_df.columns = [f'Country_{i+1}' for i in range(46) if i+1 not in skip_indices]

for i in skip_indices:
    column_name = f'Country_{i}'
    y_predicted_df.insert(loc=i-1, column=column_name, value=None)


melted_y_actual = pd.melt(y_actual_df, var_name='Countries', value_name='Measured_RYA')#数据展开
melted_y_predicted = pd.melt(y_predicted_df, var_name='Countries', value_name='Estimated_RYA')#数据展开

label_data = pd.read_excel("Input_02_for_label.xlsx",sheet_name = "Sheet1")
label_data_20 = pd.concat([label_data] * 20, axis=0).reset_index()#20年的数据
melted_data_labeled = pd.concat([label_data_20, melted_y_actual], axis=1)
result = pd.concat([melted_data_labeled, melted_y_predicted], axis=1)
result = result.drop(columns=['Countries'], axis=1)

result.to_excel("Result_03_GLC_yearly_RF_RYA_maize.xlsx")

