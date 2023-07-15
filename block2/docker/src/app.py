# AWS app version
# This is a python skeleton, you can modify this as you need

from flask import Flask, render_template, request
import boto3
import os

app = Flask(__name__)

# S3 bucket name
Bucket_Name = os.environ['BUCKET_NAME']

# S3 Client
s3_client = boto3.client('s3')

# Index route
@app.route('/')
def index():
    return render_template('index.html')

# Upload route
@app.route('/upload', methods=['POST'])
def upload():
    if 'image' not in request.files:
        return 'No image selected', 400
    
    image = request.files['image']

    # Store image in S3 bucket
    s3_client.upload_fileobj(image, Bucket_Name, image.filename)

    return 'Image upload successfully'

if __name__ == '__main__':
    app.run()
