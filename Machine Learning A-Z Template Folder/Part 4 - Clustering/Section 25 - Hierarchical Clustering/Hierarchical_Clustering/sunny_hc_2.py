# -*- coding: utf-8 -*-
"""
Created on Fri Mar 27 13:45:34 2020

@author: sunil
"""
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


#importing data sets
ds=pd.read_csv('Mall_Customers.csv')
X=ds.iloc[:,[3,4]].values

#plotting dendogram
import scipy.cluster.hierarchy as sch
dendogram=sch.dendrogram(sch.linkage(X, method='ward'))
plt.title('Dendogram')
plt.xlabel('salary')
plt.ylabel('customerscore')

#fittin model heirachical clusturing
from sklearn.cluster import AgglomerativeClustering
hc=AgglomerativeClustering(affinity='euclidean',linkage='ward',n_clusters=5)
y_hc=hc.fit_predict(X)

#plotting graph
plt.scatter(X[y_hc==0,0],X[y_hc==0,1],color='red',label='Cautious',s=100)
plt.scatter(X[y_hc==1,0],X[y_hc==1,1],color='green',label='Standerd',s=100)
plt.scatter(X[y_hc==2,0],X[y_hc==2,1],color='blue',label='target',s=100)
plt.scatter(X[y_hc==3,0],X[y_hc==3,1],color='black',label='Careless',s=100)
plt.scatter(X[y_hc==4,0],X[y_hc==4,1],color='magenta',label='Sensible',s=100)
plt.legend()
plt.show()