# -*- coding: utf-8 -*-
"""
Created on Sun Feb 28 12:40:10 2021

@author: sunil
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

ds=pd.read_csv("Position_Salaries.csv")
X=ds.iloc[:,1:-1].values
y=ds.iloc[:,-1].values

from sklearn.linear_model import LinearRegression
lin_reg=LinearRegression()
lin_reg.fit(X,y)

#Linear chart
plt.scatter(X,y,color='red', marker='+')
plt.plot(X,lin_reg.predict(X),color='green')
plt.title("Truth or Bluff-- Linear")
plt.xlabel("Years of Experience")
plt.ylabel("Salary")
plt.show()

from sklearn.preprocessing import PolynomialFeatures
poly_reg=PolynomialFeatures(degree=7)
X_poly=poly_reg.fit_transform(X)

lin_reg2=LinearRegression()
lin_reg2.fit(X_poly,y)

#polynomial chart

plt.scatter(X,y,color='red', marker='+')
plt.plot(X,lin_reg2.predict(X_poly),color='green')
plt.title("Truth or Bluff--Poly")
plt.xlabel("Years of Experience")
plt.ylabel("Salary")
plt.show()

#Finer chart plot

X_grid=np.arange(min(X),max(X),0.1)
X_grid=X_grid.reshape(len(X_grid),1)
plt.scatter(X,y,color='red', marker='+')
plt.plot(X_grid,lin_reg2.predict(poly_reg.fit_transform(X_grid)),color='green')
#plt.plot(X_grid,lin_reg2.predict(poly_reg.fit_transform(X_grid)),c='green')
plt.title("Truth or Bluff--Poly finer line")
plt.xlabel("Years of Experience")
plt.ylabel("Salary")
plt.show()



