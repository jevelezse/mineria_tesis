#!/usr/bin/env python
"""
Masked wordcloud
================
Using a mask you can generate wordclouds in arbitrary shapes.
"""

from os import path
from PIL import Image
import numpy as np
import matplotlib.pyplot as plt

from wordcloud import WordCloud

d = path.dirname(__file__)

# Read the whole text.
text = open(path.join(d, 'hc1.csv')).read()

# read the mask image
# taken from
# http://www.stencilry.org/stencils/movies/alice%20in%20wonderland/255fk.jpg
alice_mask = np.array(Image.open(path.join(d, "m.png")))

stopwords = {'si','el','un','se','al','para','del','los','de','la','le','htt','es','pero','por','muy','ten','en','las','pa',
'les','por','mas','con','no','tipo','os','a', 'al', 'algo','sin','algunas', 'algunos', 'ante', 'antes', 'como', 'con', 'contra',
'cual', 'cuando', 'de', 'del', 'y','ya','que','una','yo','dx','tiene','embargo', 'mas'}
stopwords.add("de")

wc = WordCloud(background_color="white", max_words=2000, mask=alice_mask,font_path='/home/jennifer/Descargas/cabin-sketch-v1.02/CabinSketch-Bold.ttf',
	stopwords=stopwords)
# generate word cloud
wc.generate(text)

# store to file
wc.to_file(path.join(d, "alice.png"))

# show
plt.imshow(wc, interpolation='bilinear')
plt.axis("off")
plt.figure()
plt.imshow(alice_mask, cmap=plt.cm.gray, interpolation='bilinear')
plt.axis("off")
plt.show()