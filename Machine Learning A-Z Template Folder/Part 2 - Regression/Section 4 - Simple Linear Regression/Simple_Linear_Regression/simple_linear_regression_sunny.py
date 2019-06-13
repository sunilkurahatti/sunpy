# -*- coding: utf-8 -*-
"""
Created on Thu Jun 13 14:10:42 2019

@author: skurahatti
"""
#Import the libraries
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

#imort data set

ds=pd.read_csv('Salary_Data.csv')
X=ds.iloc[:,:-1].values
y=ds.iloc[:,1].values

#split the training and test sets
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=1/3, random_state=0)

# fittinng the model to regression
from sklearn.linear_model import LinearRegression

Regressor= LinearRegression()
Regressor.fit(X_train,y_train)

#predicting the x_test results
ypred=Regressor.predict(X_test)

score=Regressor.score(X_test,y_test)

cf=Regressor.coef_

Int=Regressor.intercept_

#Plotting the graph for x_train
plt.scatter(X_train,y_train, color='red')
plt.plot(X_train, Regressor.predict(X_train), color='blue')
plt.title("Salary and Experience")
plt.xlabel("Experience")
plt.ylabel("Salary")
plt.show()


#Plotting the graph for x_test
plt.scatter(X_test,y_test, color='red')
plt.plot(X_train, Regressor.predict(X_train), color='blue')
plt.title("Salary and Experience")
plt.xlabel("Experience")
plt.ylabel("Salary")
plt.show()