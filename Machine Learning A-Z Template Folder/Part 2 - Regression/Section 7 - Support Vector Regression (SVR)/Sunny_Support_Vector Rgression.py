# -*- coding: utf-8 -*-
"""
Created on Fri Jun 14 15:53:20 2019

@author: skurahatti
"""
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

ds=pd.read_csv("Position_Salaries.csv")
X=ds.iloc[:,1:2].values
y=ds.iloc[:,2].values

# Feature scaling

from sklearn.preprocessing import StandardScaler

Sc_X=StandardScaler()
X=Sc_X.fit_transform(X)
Sc_y=StandardScaler()
#print(y.shape())
y=np.reshape(y, (len(y),1))
#y.ndim
y=Sc_y.fit_transform(y)
from sklearn.svm import SVR 

regressor=SVR(kernel='rbf')

regressor.fit(X,y)

ypred=Sc_y.inverse_transform(regressor.predict(Sc_X.transform([[6.5]])))

#Visualizing SVR regression
plt.scatter(X,y, color='red')
plt.plot(X,regressor.predict(X), color='green')
plt.title("Truth or Bluff (Linear_model)")
plt.xlabel("Position")
plt.ylabel("Salary")
plt.legend(['Posiont','salary'])
plt.show()