# -*- coding: utf-8 -*-
"""
Created on Tue Apr  6 07:01:54 2021

@author: sunil
"""
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


#importing data sets
ds=pd.read_csv('Mall_Customers.csv')
X=ds.iloc[:,[3,4]].values

#finding number of clusters
from scipy.cluster import hierarchy as sch
dendrogram=sch.dendrogram(sch.linkage(X,method='ward'))
plt.title('Dendogram')
plt.xlabel('salary')
plt.ylabel('customerscore')

#building model
from sklearn.cluster import AgglomerativeClustering
hc=AgglomerativeClustering(affinity='euclidean',linkage='ward',n_clusters=5)
y_hc=hc.fit_predict(X)

plt.scatter(X[y_hc==0,0],X[y_hc==0,1],color='red', label='Cautious',s=50)
plt.scatter(X[y_hc==1,0],X[y_hc==1,1],color='yellow', label='smart',s=50)
plt.scatter(X[y_hc==2,0],X[y_hc==2,1],color='green', label='normal',s=50)
plt.scatter(X[y_hc==3,0],X[y_hc==3,1],color='blue', label='risk-lads',s=50)
plt.scatter(X[y_hc==4,0],X[y_hc==4,1],color='black', label='under-pre',s=50)
plt.show()
print(hc.labels_)
