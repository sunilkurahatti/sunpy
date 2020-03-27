# -*- coding: utf-8 -*-
"""
Created on Fri Mar 27 07:53:09 2020

@author: sunil
"""

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

#import data set
ds=pd.read_csv('Mall_Customers.csv')
X=ds.iloc[:,[3,4]].values

#import libraries
from sklearn.cluster import KMeans
wcss=[]
for i in range(1,11):
    kmeans=KMeans(n_clusters=i,init='k-means++', n_init=10,random_state=0)
    kmeans.fit(X)
    wcss.append(kmeans.inertia_)

plt.plot(range(1,11),wcss)
plt.xlabel('clusters')
plt.ylabel('WCSS')
plt.title('elbow graph')
plt.show()

#from elbow graph we got 5 as optimal cluster number lets apply that to our model

kmeans=KMeans(n_clusters=5,init='k-means++', n_init=10,random_state=0)
y_kmeans=kmeans.fit_predict(X)

#show all clusters in graph
plt.scatter(X[y_kmeans==0,0],X[y_kmeans==0,1],color='red',label='Cautious',s=100)
plt.scatter(X[y_kmeans==1,0],X[y_kmeans==1,1],color='green',label='Standerd',s=100)
plt.scatter(X[y_kmeans==2,0],X[y_kmeans==2,1],color='blue',label='target',s=100)
plt.scatter(X[y_kmeans==3,0],X[y_kmeans==3,1],color='black',label='Careless',s=100)
plt.scatter(X[y_kmeans==4,0],X[y_kmeans==4,1],color='magenta',label='Sensible',s=100)
plt.scatter(kmeans.cluster_centers_[:,0], kmeans.cluster_centers_[:,1],color='yellow',label='cluster center',s=200)
#plt.legend()
plt.show()



































