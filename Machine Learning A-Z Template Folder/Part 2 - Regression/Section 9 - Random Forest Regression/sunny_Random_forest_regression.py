import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

ds=pd.read_csv('Position_Salaries.csv')
X=ds.iloc[:,1:2].values
y=ds.iloc[:,2].values

#fitting to random regressor with 10 trees
from sklearn.ensemble import RandomForestRegressor
regressor=RandomForestRegressor(n_estimators=10,random_state=0)
regressor.fit(X,y)

#Predicting salaries with 10 trees
y_10_pred=regressor.predict([[6.5]])

#visualizing random regressor
X_grid=np.arange(min(X),max(X),0.01)
X_grid=X_grid.reshape(len(X_grid),1)
plt.scatter(X,y,color='red')
plt.plot(X_grid,regressor.predict(X_grid),color='green')

#fitting to random regressor with 50 trees
from sklearn.ensemble import RandomForestRegressor
regressor=RandomForestRegressor(n_estimators=50,random_state=0)
regressor.fit(X,y)

#Predicting salaries with 10 trees
y_50_pred=regressor.predict([[6.5]])




#fitting to random regressor with 10 0trees
from sklearn.ensemble import RandomForestRegressor
regressor=RandomForestRegressor(n_estimators=100,random_state=0)
regressor.fit(X,y)

#Predicting salaries with 10 trees
y_100_pred=regressor.predict([[6.5]])


#fitting to random regressor with 300 trees
from sklearn.ensemble import RandomForestRegressor
regressor=RandomForestRegressor(n_estimators=300,random_state=0)
regressor.fit(X,y)

#Predicting salaries with 10 trees
y_300_pred=regressor.predict([[6.5]])

#fitting to random regressor with 500 trees
from sklearn.ensemble import RandomForestRegressor
regressor=RandomForestRegressor(n_estimators=500,random_state=0)
regressor.fit(X,y)

#Predicting salaries with 10 trees
y_500_pred=regressor.predict([[6.5]])

#end of regression