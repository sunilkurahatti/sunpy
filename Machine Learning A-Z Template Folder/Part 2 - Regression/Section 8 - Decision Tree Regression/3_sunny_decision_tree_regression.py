# -*- coding: utf-8 -*-
"""
Created on Wed Mar 10 17:36:59 2021

@author: sunil
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#importing data set
ds=pd.read_csv("Position_Salaries.csv")
X=ds.iloc[:,1:-1].values
y=ds.iloc[:,-1].values

#building model
from sklearn.tree import DecisionTreeRegressor
reg=DecisionTreeRegressor(random_state=1)
reg.fit(X,y)

#prediciting the model
y_pred=reg.predict([[6.5]])

#plotting the chart
plt.scatter(X,y, color='red')
plt.plot(X,reg.predict(X), color='green')
plt.xlabel("Experience")
plt.ylabel("Salary")
plt.title("Truth or bluff")
plt.legend()
plt.show()

#finer chart
X_grid=np.arange(min(X),max(X),0.1)
X_grid=X_grid.reshape(len(X_grid),1)
plt.scatter(X,y, color='red')
plt.plot(X_grid,reg.predict(X_grid), color='green')
plt.xlabel("Experience")
plt.ylabel("Salary")
plt.title("Truth or bluff")
plt.legend()
plt.show()