"""
This code is used to process the original crop yield data from FAOSTAT
Upated: 2024-Sep-12
By: Wanxue Zhu

"""

python

import numpy as np
import xlwt
import matplotlib.pyplot as plt
import xlrd
import math
import pandas as pd
import os



os.chdir("E:\\01_Reseach_papers\\R1_African_agriculture\\Data") 


#crop_area = pd.read_excel("FAOSTAT_yield_1990_2022.xlsx", sheet_name = "Area")
crop_yield = pd.read_excel("01_FAOSTAT_yield_1990_2022.xlsx", sheet_name = "Yield")

#crop_area = crop_area.drop(columns=['Element','Flag Description','Note'], axis = 1)
crop_yield = crop_yield.drop(columns=['Element','Flag Description','Flag','Unit'], axis = 1)

maize_yield = crop_yield[crop_yield['Item'] == 'Maize (corn)'].reset_index(drop=True)
sorghum_yield = crop_yield[crop_yield['Item'] == 'Sorghum'].reset_index(drop=True)
millet_yield = crop_yield[crop_yield['Item'] == 'Millet'].reset_index(drop=True)



data = maize_yield


years = range(1990, 2023)  # Define the range of years you want to process
data_dict = {}  # Create an empty dictionary to store the results

for year in years:
    year_data = data[data['Year'] == year].drop(columns=['Item', 'Year'])
    year_data = year_data.rename(columns={"Area": "Area", "Value": f"Y{year}"})
    data_dict[f'year_{year}'] = year_data

# Access data for a specific year
year_1990 = data_dict['year_1990']
year_1991 = data_dict['year_1991']
year_1992 = data_dict['year_1992']
year_1993 = data_dict['year_1993']
year_1994 = data_dict['year_1994']
year_1995 = data_dict['year_1995']
year_1996 = data_dict['year_1996']
year_1997 = data_dict['year_1997']
year_1998 = data_dict['year_1998']
year_1999 = data_dict['year_1999']

year_2000 = data_dict['year_2000']
year_2001 = data_dict['year_2001']
year_2002 = data_dict['year_2002']
year_2003 = data_dict['year_2003']
year_2004 = data_dict['year_2004']
year_2005 = data_dict['year_2005']
year_2006 = data_dict['year_2006']
year_2007 = data_dict['year_2007']
year_2008 = data_dict['year_2008']
year_2009 = data_dict['year_2009']

year_2010 = data_dict['year_2010']
year_2011 = data_dict['year_2011']
year_2012 = data_dict['year_2012']
year_2013 = data_dict['year_2013']
year_2014 = data_dict['year_2014']
year_2015 = data_dict['year_2015']
year_2016 = data_dict['year_2016']
year_2017 = data_dict['year_2017']
year_2018 = data_dict['year_2018']
year_2019 = data_dict['year_2019']

year_2020 = data_dict['year_2020']
year_2021 = data_dict['year_2021']
year_2022 = data_dict['year_2022']

#--------------combined all years------------


def combine_all_year():
    year_1990_1991 = pd.merge(year_1990, year_1991, on='Area', how='outer')
    year_1992_1993 = pd.merge(year_1992, year_1993, on='Area', how='outer')
    year_1994_1995 = pd.merge(year_1994, year_1995, on='Area', how='outer')
    year_1996_1997 = pd.merge(year_1996, year_1997, on='Area', how='outer')
    year_1990_1993 = pd.merge(year_1990_1991, year_1992_1993, on='Area', how='outer')
    year_1994_1997 = pd.merge(year_1994_1995, year_1996_1997, on='Area', how='outer')
    year_1990_1997 = pd.merge(year_1990_1993, year_1994_1997, on='Area', how='outer')
    year_1998_1999 = pd.merge(year_1998, year_1999, on='Area', how='outer')
    year_2000_2001 = pd.merge(year_2000, year_2001, on='Area', how='outer')
    year_2002_2003 = pd.merge(year_2002, year_2003, on='Area', how='outer')
    year_2004_2005 = pd.merge(year_2004, year_2005, on='Area', how='outer')
    year_1998_2001 = pd.merge(year_1998_1999, year_2000_2001, on='Area', how='outer')
    year_2002_2005 = pd.merge(year_2002_2003, year_2004_2005, on='Area', how='outer')
    year_1998_2005 = pd.merge(year_1998_2001, year_2002_2005, on='Area', how='outer')
    year_1990_2005 = pd.merge(year_1990_1997, year_1998_2005, on='Area', how='outer')
    year_2006_2007 = pd.merge(year_2006, year_2007, on='Area', how='outer')
    year_2008_2009 = pd.merge(year_2008, year_2009, on='Area', how='outer')
    year_2010_2011 = pd.merge(year_2010, year_2011, on='Area', how='outer')
    year_2012_2013 = pd.merge(year_2012, year_2013, on='Area', how='outer')
    year_2006_2009 = pd.merge(year_2006_2007, year_2008_2009, on='Area', how='outer')
    year_2010_2013 = pd.merge(year_2010_2011, year_2012_2013, on='Area', how='outer')
    year_2006_2013 = pd.merge(year_2006_2009, year_2010_2013, on='Area', how='outer')
    year_2014_2015 = pd.merge(year_2014, year_2015, on='Area', how='outer')
    year_2016_2017 = pd.merge(year_2016, year_2017, on='Area', how='outer')
    year_2018_2019 = pd.merge(year_2018, year_2019, on='Area', how='outer')
    year_2020_2021 = pd.merge(year_2020, year_2021, on='Area', how='outer')
    year_2014_2017 = pd.merge(year_2014_2015, year_2016_2017, on='Area', how='outer')
    year_2018_2021 = pd.merge(year_2018_2019, year_2020_2021, on='Area', how='outer')
    year_2014_2021 = pd.merge(year_2014_2017, year_2018_2021, on='Area', how='outer')
    year_2006_2021 = pd.merge(year_2006_2013, year_2014_2021, on='Area', how='outer')
    year_2006_2022 = pd.merge(year_2006_2021, year_2022, on='Area', how='outer')
    year_all = pd.merge(year_1990_2005,year_2006_2022, on='Area', how='outer')
    return(year_all)


year_all = combine_all_year()

year_all.to_excel("Maize_yield_country_level_1990_2022.xlsx")




#-----------Match FAOSTAT data with the African boundary administration used in the map

African_country = pd.read_excel("00_African_boundary.xlsx", sheet_name = "Sheet1")
maize = pd.read_excel("03_Maize_all_year.xlsx", sheet_name = "Sheet1")
millet = pd.read_excel("03_Millet_all_year.xlsx", sheet_name = "Sheet1")
sorghum = pd.read_excel("03_Sorghum_all_year.xlsx", sheet_name = "Sheet1")


African_maize = pd.merge(African_country, maize, on='NAME', how='outer')
African_sorghum = pd.merge(African_country, sorghum, on='NAME', how='outer')
African_millet = pd.merge(African_country, millet, on='NAME', how='outer')


African_maize.to_excel("Maize.xlsx")
African_sorghum.to_excel("Sorghum.xlsx")
African_millet.to_excel("Millet.xlsx")


