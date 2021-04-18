import os
from flask import Flask, render_template, request, jsonify
from werkzeug.utils import secure_filename

UPLOAD_FOLDER='data'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

app = Flask(__name__, template_folder='app/templates')

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/')
def main_app():
    return render_template('test-web-app.html')

def __allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/infer_image', methods=['POST'])
def infer_image():
    if 'file' not in request.files:
        return jsonify({'error': 'No file'})

    file = request.files['file']

    if file.filename == '':
            return jsonify({'error': 'No Filename'})
    
    if file and __allowed_file(file.filename):
        filename = secure_filename(file.filename)

        file.save(os.path.join(app.root_path, app.config['UPLOAD_FOLDER'], filename))

        return jsonify({'filename': filename})

if __name__ == '__main__':
    app.run()