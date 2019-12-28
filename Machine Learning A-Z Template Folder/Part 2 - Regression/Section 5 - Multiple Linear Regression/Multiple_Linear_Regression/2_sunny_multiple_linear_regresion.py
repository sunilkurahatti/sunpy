# -*- coding: utf-8 -*-
"""
Created on Fri Dec 27 17:06:34 2019

@author: sunil
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#importing datasets

ds=pd.read_csv("50_Startups.csv")
X=ds.iloc[:,:-1].values
y=ds.iloc[:,-1].values

#finding categorical veriables

from sklearn.preprocessing import LabelEncoder, OneHotEncoder
Le=LabelEncoder()
X[:,3]=Le.fit_transform(X[:,3])
OHE=OneHotEncoder(categorical_features=[3])
X=OHE.fit_transform(X).toarray()
X=X[:,1:]

#splitting train and test data
from sklearn.model_selection import train_test_split
X_train,X_test,y_train,y_test=train_test_split(X,y,test_size=0.2,random_state=0)

#training the model

from sklearn.linear_model import LinearRegression
reg=LinearRegression()
reg.fit(X_train,y_train)
y_pred=reg.predict(X_test)

# applyong backword elimination

import statsmodels.formula.api as sm
X_opt=np.append(arr=np.ones((50,1)).astype(int),values=X, axis=1)

X_1=X_opt[:,[0,1,2,3,4,5]]
regressor_OLS=sm.OLS(endog=y,exog=X_1).fit()
regressor_OLS.summary()

X_1=X_opt[:,[0,1,3,4,5]]
regressor_OLS=sm.OLS(endog=y,exog=X_1).fit()
regressor_OLS.summary()

X_1=X_opt[:,[0,3,4,5]]
regressor_OLS=sm.OLS(endog=y,exog=X_1).fit()
regressor_OLS.summary()

X_1=X_opt[:,[0,3,5]]
regressor_OLS=sm.OLS(endog=y,exog=X_1).fit()
regressor_OLS.summary()

X_1=X_opt[:,[0,3]]
regressor_OLS=sm.OLS(endog=y,exog=X_1).fit()
regressor_OLS.summary()