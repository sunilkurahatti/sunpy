# -*- coding: utf-8 -*-
"""
Created on Mon Jun  7 14:42:29 2021

@author: sunil
"""
#importing libraries
import pandas as pd
import numpy as np
import tensorflow as tf

print(tf.__version__)
#importing dara set
ds=pd.read_csv("Churn_Modelling.csv")
X=ds.iloc[:,3:-1].values
y=ds.iloc[:,-1].values

#Gender label encoding
from sklearn.preprocessing import LabelEncoder
le=LabelEncoder()
X[:,2]=le.fit_transform(X[:,2])

#ohe for geography field
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
ct=ColumnTransformer(transformers=[('encoder', OneHotEncoder(),[1])], remainder='passthrough')
X=ct.fit_transform(X)

#Splitting the training and test sets
from sklearn.model_selection import train_test_split
X_train,X_test,y_train,y_test= train_test_split(X,y, test_size=0.2,random_state=0)

#Applying feature scaling
from sklearn.preprocessing import StandardScaler
sc=StandardScaler()
X_train=sc.fit_transform(X_train)
X_test=sc.fit_transform(X_test)

#Building ANN
#1
ann=tf.keras.models.Sequential()

#first hidden layer
ann.add(tf.keras.layers.Dense(units=6, activation='relu'))

#second layer
ann.add(tf.keras.layers.Dense(units=6, activation='relu'))

#output layer
ann.add(tf.keras.layers.Dense(units=1,activation='sigmoid'))



#compiling the ANN
ann.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

#training ANN fromtraining data
ann.fit(X_train,y_train,batch_size=32, epochs=100)

"""
Homework:
Use our ANN model to predict if the customer with the following informations will leave the bank:
Geography: France
Credit Score: 600
Gender: Male
Age: 40 years old
Tenure: 3 years
Balance: $ 60000
Number of Products: 2
Does this customer have a credit card? Yes
Is this customer an Active Member: Yes
Estimated Salary: $ 50000
So, should we say goodbye to that customer?
"""
#predicting the homework
print(ann.predict(sc.transform([[1,0,0,600,1,40,3,60000,2,1,1,50000]]))>0.5)

#predicting the test result
y_pred=ann.predict(X_test)
y_pred= (y_pred>0.5)
print(np.concatenate((y_pred.reshape(len(y_pred),1),y_test.reshape(len(y_test),1)),1))

#building confusion matrix
from sklearn.metrics import confusion_matrix,precision_score ,recall_score
cm=confusion_matrix(y_test,y_pred)
print(precision_score(y_test,y_pred))
print(recall_score(y_test,y_pred))