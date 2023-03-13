import boto3
import requests
from bs4 import BeautifulSoup

S3_BUCKET_NAME = "data-quest-bucket"
DATA_SOURCE = "https://download.bls.gov/pub/time.series/pr/"

# Initialize S3 resource and get the bucket
s3 = boto3.resource('s3')
bucket = s3.Bucket(S3_BUCKET_NAME)

# Get bucket contents
bucket_objects = []
for obj in bucket.objects.all():
    bucket_objects.append(obj.key)
# Track files that don't exist on the website
deleted_list = bucket_objects.copy()

# Request the data source and parse it
r = requests.get(DATA_SOURCE)
soup = BeautifulSoup(r.text, 'html.parser')

for link in soup.find_all("a"):
    # Download the current file
    file_name = link.get_text()
    if file_name == "[To Parent Directory]":
        continue
    file_dl = requests.get(DATA_SOURCE + file_name)
    # If the file doesn't exist in S3, upload it
    if file_name not in bucket_objects:
        bucket.put_object(Key=file_name, Body=file_dl.content)
    # If the file exists in S3
    elif file_name in bucket_objects:
        # Get the S3 file
        s3_response = bucket.Object(file_name).get()
        s3_file_content = s3_response['Body'].read()
        # If the S3 file is different from the website file, update the S3 file
        if file_dl.content != s3_file_content:
            bucket.put_object(Key=file_name, Body=file_dl.content)
        # Remove the file from the deleted list
        deleted_list.remove(file_name)

# Remove files from S3 that are no longer on the website
for file in deleted_list:
    if file != "population.json":
        bucket.Object(file).delete()
