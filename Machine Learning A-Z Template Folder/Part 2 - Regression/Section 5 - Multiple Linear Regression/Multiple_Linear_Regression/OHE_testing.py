# -*- coding: utf-8 -*-
"""
Created on Sat Feb 27 18:02:39 2021

@author: sunil
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

ds=pd.read_csv("50_Startups.csv")
X=ds.iloc[:,:-1].values
y=ds.iloc[:,-1].values

from sklearn.preprocessing import  OneHotEncoder
OHE=OneHotEncoder(sparse=False)
from sklearn.compose import make_column_transformer
column_trans=make_column_transformer((OneHotEncoder(),[3]),remainder='passthrough')
from sklearn.model_selection import train_test_split
X_train,X_test,y_train,y_test=train_test_split(X,y,test_size=0.2, random_state=0)

from sklearn.linear_model import LinearRegression
reg=LinearRegression()

from sklearn.pipeline import make_pipeline

pipe=make_pipeline(column_trans,reg)
pipe.fit(X_train,y_train)
y_pred=pipe.predict(X_test)
column_trans.fit_transform(X_test)

X_ohe=OHE.fit_transform(X[[3]]).toarray()



X=X[:,1:]


reg.fit(X_train,y_train)
y_pred=reg.predict(X_test)