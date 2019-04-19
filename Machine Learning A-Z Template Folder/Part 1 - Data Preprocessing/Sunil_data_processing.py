# -*- coding: utf-8 -*-
"""
Created on Thu Apr 18 10:12:41 2019

@author: sunil
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.impute import SimpleImputer

dataset=pd.read_csv("Data.csv")
X=dataset.iloc[:,:-1].values
y=dataset.iloc[:,3].values


imputer=SimpleImputer(strategy='mean',missing_values=np.nan,fill_value='None')
X[:,1:3]=imputer.fit_transform(X[:,1:3])

#categorical Data
from sklearn.preprocessing import LabelEncoder,OneHotEncoder
labelencode_X=LabelEncoder()
X[:,0]=labelencode_X.fit_transform(X[:,0])

ohe=OneHotEncoder(categorical_features = [0])
X=ohe.fit_transform(X).toarray()
labelencode_y=LabelEncoder()
y=labelencode_y.fit_transform(y)

#Split test and train set
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test=train_test_split(X,y,test_size=0.2, random_state=0)

#feature Scaling
from sklearn.preprocessing import StandardScaler
sc_X=StandardScaler()
X_train=sc_X.fit_transform(X_train)
X_test=sc_X.fit_transform(X_test)
