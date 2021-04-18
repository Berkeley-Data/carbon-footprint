import flask
from flask import Flask, render_template, request, jsonify
import json
import numpy as np
import pandas as pd
from PIL import Image
import base64
from io import BytesIO
import requests

application = Flask(__name__)
application.title='Carby Endpoint'

#df = pd.read_csv('sample_product_data.csv', dtype='str')
df = pd.read_csv('https://raw.githubusercontent.com/Berkeley-Data/carbon-footprint/5355606918ae8db8adf9e40c0be3bd9fade9ed75/data/model_input.csv')
product_ids = np.array(df.code)
print(product_ids)

MODEL_URL = "http://carbymodelapi-env.eba-zfkqpc4z.us-east-1.elasticbeanstalk.com/predict-product" 

#NOT USING THIS AT THE MOMENT
@application.route("/predict", methods=['POST'])
def predict_product():
	print("******* Image bytes ******* ")
	imgdata = base64.b64decode(request.form['img'])
	
	#######Do model prediction
	print("BEGIN MODEL PREDICTION!!!")
	response = requests.post(MODEL_URL, data={"name":"water bottle", "img":request.form['img']})
	print("predicted response {}".format(response.json()))
	print("END MODEL PREDICTION!!!")

	#Randomly select 1 products
	predicted_products = list(np.random.choice(product_ids,2))
	#######End model prediction

	meta_json = return_metadata(predicted_products)

	return meta_json

#USING THIS
@application.route('/metadata/<text>')
def get_metadata(text='3068320055008'):
	meta_json = return_metadata([text])
	return meta_json


def return_metadata(arr=[]):
	df_meta = df[df.code.isin(arr)][['code', 'product_name', 'leaf_category', 'image_url', 'carbon-footprint_100g']]
	df_meta.columns = ['product_id', 'product_name', 'product_category', 'image_url', 'carbon_footprint']
	print(df_meta)
	json_return = json.loads(df_meta.to_json(orient='records'))
	return json_return[0]

if __name__ == '__main__':
    application.run(debug=True, port=8080)
