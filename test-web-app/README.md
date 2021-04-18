### Setup Dev Env

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

### Run Flask
source venv/bin/activate  
export FLASK_DEBUG=1
export FLASK_APP=test-app.py  
flask run --port=8080

### Run Docker
#### Build
From app root run `./docker/build.sh`

#### Run
From app root run `./docker/run.sh`