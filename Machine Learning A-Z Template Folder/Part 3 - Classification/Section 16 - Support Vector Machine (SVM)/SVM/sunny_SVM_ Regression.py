# -*- coding: utf-8 -*-
"""
Created on Tue Jul  2 09:49:44 2019

@author: sunil
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
%matplotlib qt

#importing datasets
ds=pd.read_csv('Social_Network_Ads.csv')
X=ds.iloc[:,[2,3]].values
y=ds.iloc[:,[4]].values

#splitting training and test data
from sklearn.model_selection import train_test_split
X_train,X_test,y_train,y_test=train_test_split(X,y,random_state=0)

#feature scaling
from sklearn.preprocessing import StandardScaler
sc=StandardScaler()
X_train=sc.fit_transform(X_train)
X_test=sc.fit_transform(X_test)

#fitting the model to SVM Regression
from sklearn.svm import SVC
classifier=SVC(kernel='linear',random_state=0)
classifier.fit(X_train,y_train)

#predicting test results
y_pred=classifier.predict(X_test)

#confusiion matricx results
from sklearn.metrics import confusion_matrix
cm=confusion_matrix(y_test,y_pred)

# Visualising the Training set results
from matplotlib.colors import ListedColormap
X_set, y_set = X_train, y_train
X1, X2 = np.meshgrid(np.arange(start = X_set[:, 0].min() - 1, stop = X_set[:, 0].max() + 1, step = 0.01),
                     np.arange(start = X_set[:, 1].min() - 1, stop = X_set[:, 1].max() + 1, step = 0.01))
plt.contourf(X1, X2, classifier.predict(np.array([X1.ravel(), X2.ravel()]).T).reshape(X1.shape),
             alpha = 0.75, cmap = ListedColormap(('red', 'green')))
plt.xlim(X1.min(), X1.max())
plt.ylim(X2.min(), X2.max())
for i, j in enumerate(np.unique(y_set)):
    plt.scatter(X_set[y_set == j, 0],
                c = ListedColormap(('red', 'green'))(i), label = j)
plt.title('SVM Regression (Training set)')
plt.xlabel('Age')
plt.ylabel('Estimated Salary')
plt.legend()
plt.show()