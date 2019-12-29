# -*- coding: utf-8 -*-
"""
Created on Sun Dec 29 13:07:59 2019

@author: sunil
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#importing datasets
ds=pd.read_csv("Position_Salaries.csv")
X=ds.iloc[:,1:2].values
y=ds.iloc[:,-1].values

#building random forrest regressor

from sklearn.ensemble import RandomForestRegressor

reg=RandomForestRegressor(n_estimators=300,random_state=40)
reg.fit(X,y)

#predicting the results
y_pred=reg.predict([[6.5]])

#visualizing the result
X_grid=np.arange(min(X),max(X),0.001)
X_grid=X_grid.reshape(len(X_grid),1)
plt.scatter(X,y,c='red',marker='.')
plt.plot(X_grid,reg.predict(X_grid),c='blue')
plt.show()
