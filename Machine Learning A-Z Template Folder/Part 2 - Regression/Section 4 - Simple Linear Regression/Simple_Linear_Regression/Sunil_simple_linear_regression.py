# -*- coding: utf-8 -*-
"""
Created on Thu Apr 25 17:21:07 2019

@author: sunil
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

dataset=pd.read_csv("Salary_Data.csv")
X=dataset.iloc[:,0].values
y=dataset.iloc[:,-1].values

#Train test split
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X,y,test_size=0.2, random_state=0)

#Fitting simple linear regression
from sklearn.linear_model import LinearRegression
regressor=LinearRegression()
regressor=regressor.fit(X_train.reshape(-1,1),y_train.reshape(-1,1))
regressor.coef_
regressor.intercept_

y_pred=regressor.predict(X_test.reshape(-1,1))

#plotting

plt.scatter(X_train,y_train, marker='+',color='red')
plt.plot(X_train,regressor.predict(X_train.reshape(-1,1)))
plt.show()

#plotting test

plt.scatter(X_test,y_test, marker='+',color='green')
plt.plot(X_train,regressor.predict(X_train.reshape(-1,1)))
plt.show()