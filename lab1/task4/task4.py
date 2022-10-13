# Import relevant tools
import cv2 as cv
import numpy as np
import scipy.io as sio




# Import flower image
img = cv.imread("original_image.jpg")
template = cv.imread("template.png")
# Remove all white from the image



cv.imshow("img",img)
template[::] = [[0,0,0] if template[i][j] == [255,255,255] else template[i][j] for i in range(0,template.shape[0]) for j in range(0,template.shape[1]) ]
cv.imshow("template",template)
cv.waitKey(0)



