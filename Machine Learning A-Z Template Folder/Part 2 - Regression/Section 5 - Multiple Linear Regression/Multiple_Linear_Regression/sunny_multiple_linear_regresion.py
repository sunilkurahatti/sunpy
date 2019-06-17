# -*- coding: utf-8 -*-
"""
Created on Mon Jun 17 19:21:36 2019

@author: sunil
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

ds=pd.read_csv('50_Startups.csv')
X=ds.iloc[:,:-1].values
y=ds.iloc[:,4].values

from sklearn.preprocessing import LabelEncoder, OneHotEncoder
labelencoder=LabelEncoder()
X[:,3]=labelencoder.fit_transform(X[:,3])
OHE=OneHotEncoder(categorical_features=[3])
X=OHE.fit_transform(X).toarray()
X=X[:,1:]

from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state = 0)

from sklearn.linear_model import LinearRegression
regressor=LinearRegression()
regressor.fit(X_train,y_train)
y_pred= regressor.predict(X_test)
print(regressor.score(X_train,y_train))
print(regressor.score(X_test,y_test))