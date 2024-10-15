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


