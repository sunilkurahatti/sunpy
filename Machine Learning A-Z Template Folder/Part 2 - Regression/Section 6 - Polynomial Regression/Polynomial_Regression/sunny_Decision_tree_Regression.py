# -*- coding: utf-8 -*-
"""
Created on Thu Jun 27 13:59:05 2019

@author: skurahatti
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

ds=pd.read_csv('Position_Salaries.csv')
X=ds.iloc[:,1:2].values
y=ds.iloc[:,2].values

from sklearn.tree import DecisionTreeRegressor
regressor=DecisionTreeRegressor(random_state=0)
regressor.fit(X,y)

y_pred=regressor.predict([[6.5]])

#Visualizing Decision Tree
plt.scatter(X,y,color='red')
plt.plot(regressor.predict(X))
plt.xlabel('Position')
plt.ylabel('salary')
plt.title('Truth or bluff (Decision tree)')
plt.legend(['position','salary'])
plt.show()

#Visualizing Decision Tree with fine line

X_grid=np.arange(min(X),max(X),0.01)
X_grid=X_grid.reshape(len(X_grid),1)
plt.scatter(X,y,color='green')
plt.plot(X_grid,regressor.predict(X_grid))
plt.xlabel('Position')
plt.ylabel('salary')
plt.title('Truth or bluff (Decision tree)')
plt.legend(['position','salary'])
plt.show()