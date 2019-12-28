# -*- coding: utf-8 -*-
"""
Created on Fri Dec 27 13:16:39 2019

@author: sunil
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#importing datasets

ds=pd.read_csv('Salary_Data.csv')
X=ds.iloc[:,[0]].values
y=ds.iloc[:,-1].values

#Splitting data

from sklearn.model_selection import train_test_split
X_train,X_test,y_train,y_test= train_test_split(X,y,test_size=0.2, random_state=4)

#applying linear regression

from sklearn.linear_model import LinearRegression

reg=LinearRegression()

reg.fit(X_train,y_train)

y_pred=reg.predict(X_test)

#visualizing train results

plt.scatter(X_train,y_train, marker='+',c='red')
plt.plot(X_train,reg.predict(X_train),c='blue')
plt.title("Sunny Salary")
plt.xlabel("Years of Exp")
plt.ylabel("Salary")
plt.show()

#visualizing test results

plt.scatter(X_test,y_test, marker='*',c='green')
plt.plot(X_train,reg.predict(X_train),c='red')
plt.title("Sunny Salary")
plt.xlabel("Years of Exp")
plt.ylabel("Salary")
plt.show()