# -*- coding: utf-8 -*-
"""
Created on Sun Dec 29 12:21:52 2019

@author: sunil
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#import datasets

ds=pd.read_csv("Position_Salaries.csv")
X=ds.iloc[:,1:2].values
y=ds.iloc[:,-1].values

#building decision tree regression

from sklearn.tree import DecisionTreeRegressor

reg=DecisionTreeRegressor(random_state=1)

reg.fit(X,y)

#predict result

y_pred=reg.predict([[6.5]])

#applying feature scaling
"""
from sklearn.preprocessing import StandardScaler
sc_X=StandardScaler()
X=sc_X.fit_transform(X)
sc_y=StandardScaler()
y=sc_y.fit_transform(y.toarray())

from sklearn.tree import DecisionTreeRegressor

reg=DecisionTreeRegressor(random_state=1)

reg.fit(X,y)

#predict result with standerd scalar

y_pred_sc=sc_y.inverse_transform(reg.predict([[6]]))
#"""

#visualizing the results

plt.scatter(X,y,c='red', marker='+')
plt.plot(X,reg.predict(X),c='pink')
plt.show()

#finer curve with small interval
X_grid=np.arange(min(X),max(X),0.01)
X_grid=X_grid.reshape(len(X_grid),1)
plt.scatter(X,y,c='red', marker='+')
plt.plot(X_grid,reg.predict(X_grid),c='442256')
plt.show()











