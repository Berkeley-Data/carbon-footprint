from loadimagesfrombytes import LoadImagesFromBytes
import detect_custom as dc
import base64
import os
import flask
from flask import Flask, request
import requests
import json

#print(os.listdir())
#with open('3700214610015.jpg', "rb") as imageFile:
    #img = base64.b64encode(imageFile.read())

#dataset = LoadImagesFromBytes(path=None, bytes_img=img, img_size=416, stride=32)
#print(len(dataset))

#result = dc.get_prediction('3700214610015.jpg', img)
#print("This is the result {} ".format(result))

app = Flask(__name__)

@app.route("/predict-product", methods=['POST'])
def predict_product():
	print("******* Image bytes ******* ")
	imgdata = base64.b64decode(request.form['img'])
	
	#dataset = LoadImagesFromBytes(path='', bytes_img=request.form['img'], img_size=416, stride=32)

	result = dc.get_prediction('3700214610015.jpg', request.form['img'])
	print("This is the result {} ".format(result))
	return result

@app.route("/send-image/<path:url>")
def predict(url):
	img = base64.b64encode(requests.get(url).content)
	dataset = LoadImagesFromBytes(path='', bytes_img=img, img_size=416, stride=32)
	#print(len(dataset))

	result = dc.get_prediction('3700214610015.jpg', img)
	#print("This is the result {} ".format(result))
	return result


@app.route('/predict/<text>')
def predict_text(text='hello'):
    response = json.dumps({'response': text})
    return response, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)