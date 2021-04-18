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

########################################
#External APIs
########################################
MODEL_URL = "http://carbymodelapi-env.eba-zfkqpc4z.us-east-1.elasticbeanstalk.com/predict-product" 


########################################
#Data Cleanup
########################################

#Original dataframe
df_original = pd.read_csv('https://raw.githubusercontent.com/Berkeley-Data/carbon-footprint/5355606918ae8db8adf9e40c0be3bd9fade9ed75/data/model_input.csv')
product_ids = np.array(df_original.code)

#Dataframe for category lookups
df = pd.read_csv('https://raw.githubusercontent.com/Berkeley-Data/carbon-footprint/main/data/model_input.csv')
df = df.assign(leaf_category=df.leaf_category.str.split(':').str[-1])
df = df.assign(leaf_category = df.leaf_category.str.replace('-', ' '))

df_expanded = df.assign(expanded=df['categories_en'].str.split(',')).explode('expanded')
df_expanded = df_expanded.assign(expanded = df_expanded.expanded.str.lower())


########################################
#ROUTES
########################################

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

#USING THIS TO GET METADATA FOR A PRODUCT ID
@application.route('/metadata/<text>')
def get_metadata(text='3068320055008'):
	meta_json = return_metadata([text])
	return meta_json

#USING THIS TO GET METADATA FOR PRODUCTS WITH LOWER FOOTPRINT
@application.route('/getlowerfootprint/metadata/<text>')
def return_recommendation(text='3068320055008') :
	print("This is the id {}".format(text))
	selected_cateogry, product_c_footprint = return_info([text])
	print("This is the selected category {} and footprint {}".format(selected_cateogry, product_c_footprint))
	for group, grouped_df in df_expanded.groupby(['expanded']) :
		if group == selected_cateogry:
			selected_df = (grouped_df[grouped_df['carbon-footprint_100g'] < product_c_footprint].sort_values(by=['carbon-footprint_100g']))
			ret_val = selected_df[['code', 'product_name', 'carbon-footprint_100g', 'leaf_category', 'image_url']].head(3).to_dict(orient='records')
			return jsonify(ret_val)


#USING THIS TO GET IDS FOR PRODUCTS WITH LOWER FOOTPRINT
@application.route('/getlowerfootprint/ids/<text>')
def return_recommendation_list(text='3068320055008') :
	selected_cateogry, product_c_footprint = return_info([text])

	for group, grouped_df in df_expanded.groupby(['expanded']) :
		if group == selected_cateogry:
			selected_df = (grouped_df[grouped_df['carbon-footprint_100g'] < product_c_footprint].sort_values(by=['carbon-footprint_100g']))
			ret_val = list(selected_df['code'])[:3]
			return jsonify(ret_val)


########################################
#Helper Functions
########################################
def return_info(arr=[]):
	tempdf = df[df.code.isin(arr)][['leaf_category', 'carbon-footprint_100g']]
	selected_cateogry = list(tempdf.leaf_category)[0]
	product_c_footprint = list(tempdf['carbon-footprint_100g'])[0]
	return selected_cateogry, product_c_footprint

def get_product_name(id) :
    name = list(df[df.code == id].product_name)[0]
    product_c_footprint = list(df[df.code == id]['carbon-footprint_100g'])[0]
    print('Product name : {}, \ncarbon-footprint_100g : {}\n\n'.format(name, product_c_footprint))

def return_metadata(arr=[]):
	df_meta = df_original[df_original.code.isin(arr)][['code', 'product_name', 'leaf_category', 'image_url', 'carbon-footprint_100g']]
	df_meta.columns = ['product_id', 'product_name', 'product_category', 'image_url', 'carbon_footprint']
	print(df_meta)
	json_return = json.loads(df_meta.to_json(orient='records'))
	return json_return[0]

if __name__ == '__main__':
    application.run(debug=True, port=8080)