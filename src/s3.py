import boto3
import botocore

from config import S3_BUCKET, S3_KEY, S3_SECRET

def getImage(filename):
    s3 = boto3.resource('s3', aws_access_key_id=S3_KEY, aws_secret_access_key=S3_SECRET)

    try:
        s3.Bucket(S3_BUCKET).download_file(filename, 's3_images/' + filename)
        return 200
    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] == "404":
            return 404
        else:
            return 500
