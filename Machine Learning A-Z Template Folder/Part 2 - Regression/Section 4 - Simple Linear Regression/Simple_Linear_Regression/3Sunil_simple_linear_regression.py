# -*- coding: utf-8 -*-
"""
Created on Wed Feb 24 14:08:34 2021

@author: sunil
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

ds=pd.read_csv('Salary_Data.csv')
X=ds.iloc[:,:-1].values
y=ds.iloc[:,-1].values

from sklearn.model_selection import train_test_split
X_train,X_test,y_train,y_test=train_test_split(X,y,test_size=0.2,random_state=0)

from sklearn.linear_model import LinearRegression
reg=LinearRegression()
reg.fit(X_train,y_train)

y_pred=reg.predict(X_test)
sal_pred=reg.predict([[6.5]])



plt.scatter(X_train,y_train,c='red',marker='+')
plt.plot(X_train,reg.predict(X_train), c='green')
plt.xlabel("Years of Experience")
plt.ylabel("Salary")
plt.title("Salary estimation")
plt.show()

plt.scatter(X_test,y_test, marker='*',c='green')
plt.plot(X_train,reg.predict(X_train),c='red')
plt.title("Sunny Salary")
plt.xlabel("Years of Exp")
plt.ylabel("Salary")
plt.show()

print(reg.coef_)
print(reg.score(X_train,y_train))