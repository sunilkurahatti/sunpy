# -*- coding: utf-8 -*-
"""
Created on Sat Dec 28 13:14:35 2019

@author: sunil
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#importing datasets
ds=pd.read_csv("Position_Salaries.csv")

X=ds.iloc[:,[1]].values
y=ds.iloc[:,2].values

#imprt linear model

from sklearn.linear_model import LinearRegression
lin_reg=LinearRegression()
lin_reg.fit(X,y)

#importing polynomial reg

from sklearn.preprocessing import PolynomialFeatures
poly_reg=PolynomialFeatures(degree=7)
X_poly=poly_reg.fit_transform(X)

lin_reg2=LinearRegression()
lin_reg2.fit(X_poly,y)

#Visualizing linear result
plt.scatter(X,y, c='red', marker='+')
plt.plot(X,lin_reg.predict(X),c='blue')
plt.title("truth or bluff")
plt.xlabel("job_level")
plt.ylabel("salary")
plt.show()


#Visualizing polynomial result
X_grid=np.arange(min(X),max(X),.1)
X_grid=X_grid.reshape((len(X_grid),1))
plt.scatter(X,y, c='red', marker='+')
plt.plot(X_grid,lin_reg2.predict(poly_reg.fit_transform(X_grid)),c='green')
plt.title("truth or bluff")
plt.xlabel("job_level")
plt.ylabel("salary")
plt.show()

#prediction of linear model

lin_reg.predict([[6.5]])

#prediction of polymomial reg

lin_reg2.predict(poly_reg.fit_transform([[14]]))