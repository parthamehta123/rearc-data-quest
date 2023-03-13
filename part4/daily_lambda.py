import boto3
import requests
from bs4 import BeautifulSoup
import os


def lambda_handler(event, context):
    S3_BUCKET_NAME = os.environ.get("S3_BUCKET_NAME")
    P1_DATA_SOURCE = "https://download.bls.gov/pub/time.series/pr/"
    P2_DATA_SOURCE = "https://datausa.io/api/data?drilldowns=Nation&measures=Population"

    # Initialize S3 resource and get the bucket
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(S3_BUCKET_NAME)
    print("bucket ", bucket)

    # Get bucket contents
    bucket_objects = []
    for obj in bucket.objects.all():
        bucket_objects.append(obj.key)
    # Track files that don't exist on the website
    deleted_list = bucket_objects.copy()
    print("bucket_objects ", bucket_objects)
    print("deleted_list ", deleted_list)

    # Request the data source and parse it
    r = requests.get(P1_DATA_SOURCE)
    soup = BeautifulSoup(r.text, 'html.parser')

    for link in soup.find_all("a"):
        # Download the current file
        file_name = link.get_text()
        print("file_name ", file_name)
        if file_name == "[To Parent Directory]":
            continue
        file_dl = requests.get(P1_DATA_SOURCE + file_name)
        print("file_dl ", file_dl)
        # If the file doesn't exist in S3, upload it
        if file_name not in bucket_objects:
            print("{} uploading to S3 ".format(file_name))
            bucket.put_object(Key=file_name, Body=file_dl.content)
        # If the file exists in S3
        elif file_name in bucket_objects:
            print("{} already exists in S3 ".format(file_name))
            # Get the S3 file
            s3_response = bucket.Object(file_name).get()
            s3_file_content = s3_response['Body'].read()
            # If the S3 file is different from the website file, update the S3 file
            if file_dl.content != s3_file_content:
                print("file content is different on website so updating the S3 file with new content")
                print("file_name ", file_name)
                bucket.put_object(Key=file_name, Body=file_dl.content)
            # Remove the file from the deleted list
            deleted_list.remove(file_name)
            print("deleted_list ", deleted_list)

    # Remove files from S3 that are no longer on the website
    for file in deleted_list:
        print("file ", file)
        print("deleted_list ", deleted_list)
        if file != "population.json":
            print("file {} not available on website deleted from S3 ", file)
            bucket.Object(file).delete()

    # Request the API data and parse it
    r = requests.get(P2_DATA_SOURCE)
    data = r.text

    # Upload the data to S3
    bucket.put_object(Key="population.json", Body=data)

    return "Data processing complete."
