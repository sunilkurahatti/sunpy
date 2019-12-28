# -*- coding: utf-8 -*-
"""
Created on Sat Dec 28 17:24:44 2019

@author: sunil
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# importing datasets
ds=pd.read_csv("Position_Salaries.csv")
X=ds.iloc[:, 1:2].values
y=ds.iloc[:,[-1]].values

#applying standerd scalar

from sklearn.preprocessing import StandardScaler
sc_X=StandardScaler()
sc_y=StandardScaler()
X=sc_X.fit_transform(X)
y=sc_y.fit_transform(y)

#applying SVM regression

from sklearn.svm import SVR
regressor=SVR(kernel='rbf')
regressor.fit(X,y)

#visualizing the regressor
plt.scatter(X,y,c='green')
plt.plot(X,regressor.predict(X),c='red')
plt.show()

#prediction

y_pred=sc_y.inverse_transform(regressor.predict(sc_X.transform([[6.5]])))