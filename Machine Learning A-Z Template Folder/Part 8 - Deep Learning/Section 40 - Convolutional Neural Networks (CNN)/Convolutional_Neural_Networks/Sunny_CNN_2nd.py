# -*- coding: utf-8 -*-
"""
Created on Tue Mar 31 12:40:38 2020

@author: sunil
"""

from keras.models import Sequential
from keras.layers import Conv2D
from keras.layers import MaxPool2D
from keras.layers import Flatten
from keras.layers import Dense

#building CNN classification

classifier=Sequential()

#adding convolution layer
classifier.add(Conv2D(32,3,activation='relu',padding='same',input_shape = (64, 64, 3)))

#adding pooling layer
classifier.add(MaxPool2D())

#adding flattening
classifier.add(Flatten())

#creating full connection
classifier.add(Dense(activation='relu',units=128))

classifier.add(Dense(activation='sigmoid', units=1))

classifier.compile(optimizer='adam',loss='binary_crossentropy',metrics=['accuracy'])

from keras.preprocessing.image import ImageDataGenerator

train_datagen = ImageDataGenerator(rescale = 1./255,
                                   shear_range = 0.2,
                                   zoom_range = 0.2,
                                   horizontal_flip = True)

test_datagen = ImageDataGenerator(rescale = 1./255)

training_set = train_datagen.flow_from_directory('dataset/training_set',
                                                 target_size = (64, 64),
                                                 batch_size = 32,
                                                 class_mode = 'binary')

test_set = test_datagen.flow_from_directory('dataset/test_set',
                                            target_size = (64, 64),
                                            batch_size = 32,
                                            class_mode = 'binary')

classifier.fit_generator(training_set,
                         samples_per_epoch = 8000,
                         nb_epoch = 25,
                         validation_data = test_set,
                         nb_val_samples = 2000)