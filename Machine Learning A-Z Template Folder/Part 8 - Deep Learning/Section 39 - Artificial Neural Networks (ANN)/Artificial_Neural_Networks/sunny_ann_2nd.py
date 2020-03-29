# -*- coding: utf-8 -*-
"""
Created on Sun Mar 29 16:58:22 2020

@author: sunil
"""
import numpy as np
import pandas as pd

#importing datasets
ds=pd.read_csv('Churn_Modelling.csv')

X=ds.iloc[:,3:13].values
y=ds.iloc[:,13].values

#dealing with categorical featurs
from sklearn.preprocessing import OneHotEncoder, LabelEncoder
LabelEncoder_X_1=LabelEncoder()
X[:,1]=LabelEncoder_X_1.fit_transform(X[:,1])
LabelEncoder_X_2=LabelEncoder()
X[:,2]=LabelEncoder_X_2.fit_transform(X[:,2])
ohe=OneHotEncoder(categorical_features=[1])
X=ohe.fit_transform(X).toarray()
X=X[:,1:]


#applying feature scaling
from sklearn.preprocessing import StandardScaler
sc=StandardScaler()
X=sc.fit_transform(X)

#splittig dataset
from sklearn.model_selection import train_test_split
X_train,X_test,y_train,y_test=train_test_split(X,y,random_state=0,test_size=0.2)

#Applyin ANN
import keras
from keras.models import Sequential
from keras.layers import Dense

#bulding layers
classifier=Sequential()

#Building hidden layer

classifier.add(Dense(activation='relu',kernel_initializer='uniform',input_dim=11, output_dim=6))

#adding second layer
classifier.add(Dense(activation='relu',kernel_initializer='uniform', output_dim=6))

#adding third layer
classifier.add(Dense(activation='relu',kernel_initializer='uniform', output_dim=6))

#adding fourth layer
classifier.add(Dense(activation='relu',kernel_initializer='uniform', output_dim=6))

classifier.add(Dense(activation='relu',kernel_initializer='uniform', output_dim=6))
#adding output layer

classifier.add(Dense(activation='sigmoid',kernel_initializer='uniform', output_dim=1))

#adding compiler

classifier.compile(optimizer = 'adam', loss = 'binary_crossentropy', metrics = ['accuracy'])

#fitting model to classifiers
classifier.fit(X_train,y_train,batch_size=5, epochs=100)

#predicting test sets
y_pred=classifier.predict(X_test)
y_pred=(y_pred>0.5)

#confusin matrix
from sklearn.metrics import confusion_matrix, recall_score
cm=confusion_matrix(y_test,y_pred)


from keras.optimizers import sgd

sgd=sgd()

