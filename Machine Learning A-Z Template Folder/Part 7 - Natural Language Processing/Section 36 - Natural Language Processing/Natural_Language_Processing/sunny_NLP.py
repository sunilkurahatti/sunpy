# -*- coding: utf-8 -*-
"""
Created on Fri Jul  5 15:34:58 2019

@author: skurahatti
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

#importimg dataset
ds=pd.read_csv('Restaurant_Reviews.tsv',delimiter='\t', quoting=3)

#cleaning the data
import re
import nltk
from nltk.corpus import stopwords
from nltk.stem.porter import PorterStemmer
ps=PorterStemmer()
nltk.download('stopwords')
corpus_sunny=[]
for i in range(0,1000):
    review=ds['Review'][i]
    review=re.sub('[^a-zA-Z]',' ',review)
    review=review.lower()
    review=review.split()
    review=[ps.stem(word) for word in review if not word in set(stopwords.words('english'))]
    review=' '.join(review)
    corpus_sunny.append(review)

#building bag of words
from sklearn.feature_extraction.text import CountVectorizer
cv=CountVectorizer(max_features =1500)
X=cv.fit_transform(corpus_sunny).toarray()
y=ds['Liked'].values

#splitting datasets
from sklearn.model_selection import train_test_split
X_train,X_test,y_train,y_test=train_test_split(X,y,test_size=0.20, random_state=0)

# Fitting Naive Bayes to the Training set
from sklearn.naive_bayes import GaussianNB
classifier = GaussianNB()
classifier.fit(X_train, y_train)

# Predicting the Test set results
y_pred = classifier.predict(X_test)

# Making the Confusion Matrix
from sklearn.metrics import confusion_matrix
cm = confusion_matrix(y_test, y_pred)




