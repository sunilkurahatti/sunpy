# -*- coding: utf-8 -*-
"""
Created on Wed Jul  3 16:02:13 2019

@author: skurahatti
"""
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
%matplotlib qt
#importing datasets
ds=pd.read_csv('Mall_Customers.csv')
X=ds.iloc[:,[3,4]].values

#finding optimum cluster
from sklearn.cluster import KMeans
wcss=[]

for i in range(1,11):
    KM=KMeans(n_clusters=i,init='k-means++',n_init=10,max_iter=300,random_state=0)
    KM.fit(X)
    wcss.append(KM.inertia_)
plt.plot(range(1,11),wcss)
plt.xlabel('number of clusters')
plt.ylabel('wcss')
plt.title('Elbow Graph')
plt.show()


KM=KMeans(n_clusters=5,init='k-means++',random_state=0)
y_kmeans=KM.fit_predict(X)

#plot scatter plot
plt.scatter(X[y_kmeans==0,0],X[y_kmeans==0,1],color='red',label='Cautious',s=100)
plt.scatter(X[y_kmeans==1,0],X[y_kmeans==1,1],color='green',label='Standerd',s=100)
plt.scatter(X[y_kmeans==2,0],X[y_kmeans==2,1],color='blue',label='target',s=100)
plt.scatter(X[y_kmeans==3,0],X[y_kmeans==3,1],color='black',label='Careless',s=100)
plt.scatter(X[y_kmeans==4,0],X[y_kmeans==4,1],color='magenta',label='Sensible',s=100)
plt.scatter(KM.cluster_centers_[:,0], KM.cluster_centers_[:,1],color='yellow',label='cluster center',s=300)
plt.legend()
plt.show()