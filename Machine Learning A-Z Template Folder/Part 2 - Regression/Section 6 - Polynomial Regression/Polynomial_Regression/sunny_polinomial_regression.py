# -*- coding: utf-8 -*-
"""
Created on Tue Jun 18 17:10:37 2019

@author: sunil
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

ds=pd.read_csv("Position_Salaries.csv")
X=ds.iloc[:,1:2].values
y=ds.iloc[:,2].values

from sklearn.linear_model import LinearRegression
line_reg=LinearRegression()
line_reg.fit(X,y)

from sklearn.preprocessing import PolynomialFeatures
poly_reg=PolynomialFeatures(degree=6)
X_poly=poly_reg.fit_transform(X)
poly_reg.fit(X_poly,y)
line_reg2=LinearRegression()
line_reg2.fit(X_poly,y)

#Visualizing linear regression
plt.scatter(X,y, color='red')
plt.plot(X,line_reg.predict(X), color='green')
plt.title("Truth or Bluff (Linear_model)")
plt.xlabel("Position")
plt.ylabel("Salary")
plt.legend(['Posiont','salary'])
plt.show()
#Visualizing poly_reg regression
plt.scatter(X,y, color='red')
plt.plot(X,line_reg2.predict(poly_reg.fit_transform(X)), color='green')
plt.title("Truth or Bluff (Linear_model)")
plt.xlabel("Position")
plt.ylabel("Salary")
plt.legend(['Posiont','salary'])
plt.show()

#visualizing more finer curve
X_grid=np.arange(min(X),max(X),0.1)
X_grid = X_grid.reshape((len(X_grid), 1))
plt.scatter(X,y, color='red')
plt.plot(X_grid,line_reg2.predict(poly_reg.fit_transform(X_grid)), color='green')
plt.title("Truth or Bluff (Linear_model)")
plt.xlabel("Position")
plt.ylabel("Salary")
plt.legend(['Posiont','salary'])
plt.show()

#predicting linear model

line_reg.predict([[6.5]])
#predicting polynomial model

line_reg2.predict(poly_reg.fit_transform([[6.5]]))