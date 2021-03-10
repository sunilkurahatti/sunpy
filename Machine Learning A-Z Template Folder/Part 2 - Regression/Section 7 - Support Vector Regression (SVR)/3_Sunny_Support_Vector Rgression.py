# -*- coding: utf-8 -*-
"""
Created on Mon Mar  8 13:43:04 2021

@author: sunil
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#importing data set

ds=pd.read_csv("Position_Salaries.csv")
X=ds.iloc[:,1:-1].values
y=ds.iloc[:,-1].values

#applying standerd scalar
from sklearn.preprocessing import StandardScaler
sc_X=StandardScaler()
sc_y=StandardScaler()
X=sc_X.fit_transform(X)
y=sc_y.fit_transform(y.reshape(len(y),1))

#training the model
from sklearn.svm import SVR
sv_reg=SVR(kernel='rbf')
sv_reg.fit(X,y)

#Predicting svr
y_pred=sc_y.inverse_transform(sv_reg.predict(sc_X.transform([[6.5]])))

#plotting the chart
plt.scatter(sc_X.inverse_transform(X),sc_y.inverse_transform(y))
plt.plot(sc_X.inverse_transform(X),sc_y.inverse_transform(sv_reg.predict(X)))
plt.show

plt.scatter(X,y)
plt.plot(X,sv_reg.predict(X))
plt.show