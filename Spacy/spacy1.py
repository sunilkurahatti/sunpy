# -*- coding: utf-8 -*-
"""
Created on Tue Jul 23 11:11:22 2019

@author: sunil
"""

import spacy

nlp=spacy.load('en_core_web_sm')

di=nlp(u"sunil")

print(di)