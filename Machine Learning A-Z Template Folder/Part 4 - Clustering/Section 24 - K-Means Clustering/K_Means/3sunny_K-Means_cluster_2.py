# -*- coding: utf-8 -*-
"""
Created on Tue Apr  6 06:16:57 2021

@author: sunil
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

#importing datasets
ds=pd.read_csv("Mall_Customers.csv")
X=ds.iloc[:,[3,4]].values

#finding number of clusters
from sklearn.cluster import KMeans
wcss=[]
for i in range(1,11):
    cluster=KMeans(n_clusters=i,random_state=0,init='k-means++',n_init=10)
    cluster.fit(X)
    wcss.append(cluster.inertia_)

plt.plot(range(1,11),wcss)
plt.xlabel("number of clusters")
plt.ylabel("WCSS")
plt.title("K-Means Elbow braph")
plt.show()

#building model
clusters=KMeans(n_clusters=5,random_state=0,init='k-means++',n_init=10)
y_kmeans=clusters.fit_predict(X)

#plotting the clusters
plt.scatter(X[y_kmeans==0,0],X[y_kmeans==0,1],color='red',label='Cautious',s=50)
plt.scatter(X[y_kmeans==1,0],X[y_kmeans==1,1],color='green',label='Cautious',s=50)
plt.scatter(X[y_kmeans==2,0],X[y_kmeans==2,1],color='yellow',label='Cautious',s=50)
plt.scatter(X[y_kmeans==3,0],X[y_kmeans==3,1],color='blue',label='Cautious',s=50)
plt.scatter(X[y_kmeans==4,0],X[y_kmeans==4,1],color='magenta',label='Cautious',s=50)
plt.scatter(clusters.cluster_centers_[:,0],clusters.cluster_centers_[:,1],color='black',label='center',s=100)
plt.show()